using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace UltraStarFox.Tools.EndText
{
	// If regular expression patterns in ExtractStages, ExtractSectors or ExtractAndross,
	// check also the logic of AddStage because currently, it directly uses the enum value
	// as the match group index.
	internal enum StageTextGrouping : byte
	{
		SharedStage = 4,
		GermanStageWithoutOffset,
		GermanStageWithOffset
	}

	internal static class Program
	{
		// Reads SF/ASM/ENDSEQ.ASM whose path is supplied on the command line, then
		// puts the localizable strings to ENDTEXT.ASM and their usage in a modified
		// endseq.asm named ENDSEQNU.ASM .
		static void Main(string[] args)
		{
			Encoding encoding;
			try {
				// This can fail on macOS
				encoding = Encoding.GetEncoding("iso-8859-15");
			} catch (ArgumentException) {
				// Use a fallback encoding then
#if NETFRAMEWORK || NETCOREAPP3_1
				encoding = Encoding.Default;
#else
				encoding = Encoding.Latin1;
#endif
			}

			var strEndSeqAsm = File.ReadAllText(args[0], encoding);
			var dicJapanese = new SortedDictionary<string, string>();
			var dicEnglish = new SortedDictionary<string, string>();
			var dicGerman = new SortedDictionary<string, string>();

			strEndSeqAsm = ExtractStages(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractSectors(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractArmada(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractBosses(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractAndross(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);

			// Start a crude French and a cruder Spanish translation with common words
			var dicFrench = new SortedDictionary<string, string>();
			var dicSpanish = new SortedDictionary<string, string>();
			foreach (var kvp in dicEnglish) {
				dicFrench.Add(kvp.Key, kvp.Value.Replace("NAME   -", "NOM    -").Replace("WEAPON -", "ARME   -")
				 .Replace("SIZE   -", "TAILLE -").Replace("LEVEL ", "ROUTE ").Replace("SECTOR ", "SECTEUR ")
				 .Replace("*W", "*L").Replace("*D", "*P").Replace("ASTEROID", "ASTEROIDE").Replace("METEOR", "METEORE"));
				dicSpanish.Add(kvp.Key, kvp.Value.Replace("NAME   -", "NOMBRE -").Replace("WEAPON -", "ARMA   -")
				 .Replace("SIZE   -", "MEDIDAS-").Replace("LEVEL ", "NIVEL "));
			}

			// Merge identical terms, using English as base
			// a. Find duplicates
			var dicFrequencies = new Dictionary<string, int>(dicEnglish.Count);
			foreach (var text in dicEnglish.Values) {
				if (!dicFrequencies.TryAdd(text, 1)) {
					dicFrequencies[text]++;
				}
			}
			var lstRepeated = dicFrequencies.Where(IsDuplicated).Select(KeyOf).ToList();
			// b. Squash duplicates
			foreach (var text in lstRepeated) {
				var strNewKey = "bossgentxt_" + text.Replace(" ", "").Replace('-', '_').Replace('*', '_').ToLowerInvariant();
				if (strNewKey.EndsWith("_")) {
					strNewKey = strNewKey.Substring(0, strNewKey.Length - 1);
				}
				var strarOldKeys = dicEnglish.Where(x => x.Value == text).Select(KeyOf).ToArray();
				var strOldKey = strarOldKeys[0];

				dicEnglish.Add(strNewKey, text);
				dicJapanese.Add(strNewKey, dicJapanese[strOldKey]);
				dicGerman.Add(strNewKey, dicGerman[strOldKey]);
				dicFrench.Add(strNewKey, dicFrench[strOldKey]);
				dicSpanish.Add(strNewKey, dicSpanish[strOldKey]);
				for (var i = 0; i < strarOldKeys.Length; i++) {
					strOldKey = strarOldKeys[i];
					dicEnglish.Remove(strOldKey);
					dicJapanese.Remove(strOldKey);
					dicGerman.Remove(strOldKey);
					dicFrench.Remove(strOldKey);
					dicSpanish.Remove(strOldKey);
					strEndSeqAsm = strEndSeqAsm.Replace(strOldKey, strNewKey);
				}
			}

			// Add include directive to endtext.asm inside future endseqnu.asm
			strEndSeqAsm = Regex.Replace(strEndSeqAsm, @"incpublics\tEXT\\endseq.ext", "$0\r\n\tinclude\tASM\\endtext.asm");

			// On Windows, the program itself, not the OS, is responsible for setting the console output character set.
			Console.OutputEncoding = encoding;
			using (var wrtEndText = new StreamWriter("ENDTEXT.ASM", false, encoding)) {
				OutputDictionary(wrtEndText, dicJapanese, dicEnglish, dicGerman, dicFrench, dicSpanish);
			}
			//*
			using (var wrtEndSeqNew = new StreamWriter("ENDSEQNU.ASM", false, encoding)) {
				strEndSeqAsm = strEndSeqAsm.Replace("\r\n", "\n").Replace("\n", "\r\n");	// normalize to CRLF
				wrtEndSeqNew.WriteFileLine(strEndSeqAsm);
			}// */
		}

		private static string ExtractStages(string assemblySourceCode,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german)
		{
			const string kStagePattern =
			 @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z 0-9]+)'\W+ELSEIF\W+DB\t'([A-Z 0-9]+)'\W+ENDC\W+;.*\W+.*\W+SETDPOS\t9[*]32[+]6\W+DB\t'([A-Z]+)'";
			var colMatches = Regex.Matches(assemblySourceCode, kStagePattern);
			var c = colMatches.Count;

			for (var i = 0; i < c; i++) {
				AddStage(japanese, english, german, colMatches, i, StageTextGrouping.SharedStage);
			}
			return assemblySourceCode.VarReplace(kStagePattern,
			 "$1\tSETDPOS\t7*32+6\n\t@level\n\tSETDPOS\t9*32+6\n\t@stage");
		}

		private static string ExtractSectors(string assemblySourceCode,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german)
		{
			const string kSectorPattern =
			 @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t['""]([A-Z 0-9]+)['""]\W+ELSEIF\W+DB\t['""]([A-Z 0-9]+)['""]\W+ENDC(?:\W+;.*\W+.*)?\W+SETDPOS\t([89])[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t['""]([A-Z #$%]+)['""]\W+ELSEIF\W+DB\t['""]([A-Z #$%]+)['""]\W+ENDC";
			var colMatches = Regex.Matches(assemblySourceCode, kSectorPattern);
			var c = colMatches.Count;

			for (var i = 0; i < c; i++) {
				AddStage(japanese, english, german, colMatches, i, StageTextGrouping.GermanStageWithOffset);
			}
			return assemblySourceCode.VarReplace(kSectorPattern,
				"$1\tSETDPOS\t7*32+6\n\t@level\n\tSETDPOS\t$4*32+6\n\t@stage");
		}

		private static string ExtractArmada(string assemblySourceCode,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german)
		{
			const string kArmadaPattern =
			 @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z 0-9]+)'\W+ELSEIF\W+DB\t'([A-Z 0-9]+)'\W+ENDC\W+;.*\W+.*\W+SETDPOS\t9[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z #$%]+)'\W+ELSEIF\W+DB\t'([A-Z #$%-]+)'\W+ENDC\W+SETDPOS\t11[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z]+)'\W+ELSEIF\W+DB\t'([A-Z]+)'\W+ENDC";
			var colMatches = Regex.Matches(assemblySourceCode, kArmadaPattern);
			var c = colMatches.Count;

			for (var i = 0; i < c; i++) {
				var match = AddStage(japanese, english, german, colMatches, i,
					StageTextGrouping.GermanStageWithoutOffset);
				var strLabel  = match[1].Value;
				var strArmada = match[6].Value;

				japanese.Add(strLabel + "_stage2", strArmada);
				english.Add(strLabel + "_stage2", strArmada);
				german.Add(strLabel + "_stage2", match[7].Value);
			}
			return assemblySourceCode.VarReplace(kArmadaPattern,
			 "$1\tSETDPOS\t7*32+6\n\t@level\n\tSETDPOS\t9*32+6\n\t@stage\n\tSETDPOS\t11*32+6\n\t@stage2");
		}

		private static GroupCollection AddStage(IDictionary<string, string> japanese, IDictionary<string, string> english,
		IDictionary<string, string> german, MatchCollection colMatches, int i, StageTextGrouping grouping)
		{
			var match    = colMatches[i].Groups;
			var strLabel = match[1].Value;
			var strRoute = match[2].Value;
			var strStage = (grouping == StageTextGrouping.GermanStageWithOffset) ? match[5].Value : match[4].Value;

			Add(japanese, strLabel, strRoute, strStage);
			Add(english, strLabel, strRoute, strStage);
			Add(german, strLabel, match[3].Value, match[(int)grouping].Value);

			return match;
		}

		private static string ExtractBosses(string assemblySourceCode,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german)
		{
			const string kBossPattern =
			 @"([A-Za-z0-9]+)\W+SETDPOS\t25[*]32[+]6\W+DB\t""([A-Z -]+)""\W+SETDPOS\t26[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z -]+)""\W+ELSEIF\W+DB\t""([A-Z -]+)""\W+ENDC\W+SETDPOS\t27[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z0-9 *-]+)""\W+ELSEIF\W+DB\t""([A-Z0-9 *-]+)""\W+ENDC";
			var colMatches = Regex.Matches(assemblySourceCode, kBossPattern);
			var c = colMatches.Count;

			for (var i = 0; i < c; i++) {
				var match = colMatches[i].Groups;
				var strLabel = match[1].Value;
				var strName = match[2].Value;
				var strWeapon = match[3].Value;
				var strSize = match[5].Value;

				Add(japanese, strLabel, strName, strWeapon, strSize);
				Add(english, strLabel, strName, strWeapon, strSize);
				Add(german, strLabel, strName, match[4].Value, match[6].Value);
			}
			return assemblySourceCode.VarReplace(kBossPattern,
			 "$1\tSETDPOS\t25*32+6\n\t@namek\n\t@namev\n\tSETDPOS\t26*32+6\n\t@weaponk\n\t@weaponv\n\tSETDPOS\t27*32+6\n\t@sizek\n\t@sizev");
		}

		private static string ExtractAndross(string assemblySourceCode,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german)
		{
			const string kAndrossPattern =
			 @"([A-Za-z0-9]+)\tSETDPOS\t25[*]32[+]6\W+ifne\tJAPANESE\W+DB\t""([A-Z .-]+)""\W+elseif\W+DB\t""([A-Z .-]+)""\W+endc\W+SETDPOS\t26[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z -]+)""\W+ELSEIF\W+DB\t""([A-Z -]+)""\W+ENDC\W+SETDPOS\t27[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z0-9 *-]+)""\W+ELSEIF\W+DB\t""([A-Z0-9 *-]+)""\W+ENDC";
			var colMatches = Regex.Matches(assemblySourceCode, kAndrossPattern);
			var c = colMatches.Count;

			for (var i = 0; i < c; i++) {
				var match = colMatches[i].Groups;
				var strLabel = match[1].Value;
				var strName = match[3].Value;
				var strWeapon = match[4].Value;
				var strSize = match[6].Value;

				Add(japanese, strLabel, match[2].Value, strWeapon, strSize);
				Add(english, strLabel, strName, strWeapon, strSize);
				Add(german, strLabel, strName, match[5].Value, match[7].Value);
			}
			return assemblySourceCode.VarReplace(kAndrossPattern,
			 "$1\tSETDPOS\t25*32+6\n\t@namek\n\t@namev\n\tSETDPOS\t26*32+6\n\t@weaponk\n\t@weaponv\n\tSETDPOS\t27*32+6\n\t@sizek\n\t@sizev");
		}

		private static void Add(IDictionary<string, string> destination, string label,
		string name, string weapon, string size)
		{
			AddFeature(destination, label, "name", name);
			AddFeature(destination, label, "weapon", weapon);
			AddFeature(destination, label, "size", size);
		}

		private static void AddFeature(IDictionary<string, string> destination, string label, string featureName, string featureLine)
		{
			var strKeyPrefix = label + "_" + featureName;
			var intAfterHyphen = featureLine.IndexOf('-') + 2;
			destination.Add(strKeyPrefix + "k", featureLine.Substring(0, intAfterHyphen));
			destination.Add(strKeyPrefix + "v", featureLine.Substring(intAfterHyphen));
		}

		private static void Add(IDictionary<string, string> destination, string label, string level, string stage)
		{
			destination.Add(label + "_level", level);
			destination.Add(label + "_stage", stage);
		}

		private static string VarReplace(this string assemblySourceCode, string regexSearchPatter, string replacementPattern)
		{
			// You want space cash, it's there
			var expandedPattern = Regex.Replace(replacementPattern, @"@([a-z0-9]+)", "RUN\t' DB \"%£_$1\"'").Replace("£", "£$1");
			return Regex.Replace(assemblySourceCode, regexSearchPatter, expandedPattern).Replace('£', '$');
		}

		private static bool IsDuplicated(KeyValuePair<string, int> freq)
		{
			return freq.Value > 1;
		}

		private static string KeyOf<T>(KeyValuePair<string, T> freq)
		{
			return freq.Key;
		}

		private static void OutputDictionary(TextWriter writer,
		IDictionary<string, string> japanese, IDictionary<string, string> english, IDictionary<string, string> german,
		IDictionary<string, string> french, IDictionary<string, string> spanish)
		{
			writer.Write("; Character set of this file is ");
			writer.Write(writer.Encoding.WebName);
			writer.WriteFileLine(".").WriteFileLine();

			writer.WriteFileLine("; The value between square brackets must be strictly greater than");
			writer.WriteFileLine("; the length of the text between double quotes, but 150 maximum.");
			writer.WriteFileLine("; It means the maximum string length is 149 characters.").WriteFileLine();

			OutputDictionary(writer, "GERMAN", german);
			OutputDictionary(writer, "FRENCH", french);
			OutputDictionary(writer, "JAPANESE", japanese);
			OutputDictionary(writer, "SPANISH", spanish);
			OutputDictionary(writer, english);
		}

		private static void OutputDictionary(TextWriter writer, string language, IDictionary<string, string> dictionary)
		{
			writer.Write("\tIFNE\t");
			writer.WriteFileLine(language);
			CommonOutputDictionary(writer, dictionary);
		}

		private static void OutputDictionary(TextWriter writer, IDictionary<string, string> dictionary)
		{
			writer.WriteFileLine("\tIFEQ\tGERMAN+FRENCH+JAPANESE+SPANISH");
			CommonOutputDictionary(writer, dictionary);
		}

		private static void CommonOutputDictionary(TextWriter writer, IDictionary<string, string> dictionary)
		{
			foreach (var kvp in dictionary) {
				// STRING bossgentxt_level1="LEVEL 1"
				writer.Write("\tSTRING\t");
				writer.Write(kvp.Key);
				writer.Write("[");
				writer.Write(kvp.Value.Length + 1);	// works like a good old C char[], with an extra \0 at the end
				writer.Write("]=\"");
				writer.Write(kvp.Value.Replace("%", "%%"));	// this stuff is inserted printf-style, so escape any %
				writer.WriteFileLine("\"");
			}
			writer.WriteFileLine("\tENDC").WriteFileLine();
		}

		private static TextWriter WriteFileLine(this TextWriter writer, string text)
		{
			if (writer is StreamWriter) {	// Force CRLF when we write files
				writer.Write(text);
				writer.Write("\r\n");
			} else {    // Use platform new line for console output
				writer.WriteLine(text);
			}
			return writer;	// Allow call chaining
		}

		private static TextWriter WriteFileLine(this TextWriter writer)
		{
			writer.Write(writer is StreamWriter ? "\r\n" : Environment.NewLine);
			return writer;
		}

#if NETFRAMEWORK
		private static bool TryAdd<K, V>(this Dictionary<K, V> self, K key, V value)
		{
			// Shut up, this is the polyfill
			// ReSharper disable once CanSimplifyDictionaryLookupWithTryAdd
			if (self.ContainsKey(key)) {
				return false;
			} else {
				self.Add(key, value);
				return true;
			}
		}
#endif
	}
}
