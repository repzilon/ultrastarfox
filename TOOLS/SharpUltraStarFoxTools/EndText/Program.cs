using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace UltraStarFox.Tools.EndText
{
	internal static class Program
	{
		// Reads SF/ASM/ENDSEQ.ASM whose path is supplied on the command line and
		// puts the localizable strings to the standard output.
		static void Main(string[] args)
		{
			Encoding encoding = null;
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
			var dicJapanese = new Dictionary<string, string>();
			var dicEnglish = new Dictionary<string, string>();
			var dicGerman = new Dictionary<string, string>();

			strEndSeqAsm = ExtractStages(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractSectors(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractArmada(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractBosses(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);
			strEndSeqAsm = ExtractAndross(strEndSeqAsm, dicJapanese, dicEnglish, dicGerman);

			// Start a crude French and a cruder Spanish translation with common words
			var dicFrench = new Dictionary<string, string>();
			var dicSpanish = new Dictionary<string, string>();
			foreach (var kvp in dicEnglish) {
				dicFrench.Add(kvp.Key, kvp.Value.Replace("NAME   -", "NOM    -").Replace("WEAPON -", "ARME   -")
					.Replace("SIZE   -", "TAILLE -").Replace("LEVEL ", "ROUTE ").Replace("SECTOR ", "SECTEUR ")
					.Replace("*W", "*L").Replace("*D", "*P").Replace("ASTEROID", "ASTEROIDE").Replace("METEOR", "METEORE"));
				// Do you have a synonym for "tamaño" that neither use ~ nor tone accents?
				dicSpanish.Add(kvp.Key, kvp.Value.Replace("NAME   -", "NOMBRE -").Replace("WEAPON -", "ARMA   -")
					.Replace("LEVEL ", "NIVEL "));
			}

			// On Windows, the program itself, not the OS, is responsible for setting the console output character set.
			Console.OutputEncoding = encoding;
			using (var wrtEndText = new StreamWriter("endtext.asm", false, encoding)) {
				OutputDictionary(wrtEndText, dicJapanese, dicEnglish, dicGerman, dicFrench, dicSpanish);
			}
			//*
			using (var wrtEndSeqNew = new StreamWriter("endseqnu.asm", false, encoding)) {
				wrtEndSeqNew.WriteLine(strEndSeqAsm);
			}// */
		}

		private static string ExtractStages(string assemblySourceCode,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german)
		{
			const string kStagePattern = @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z 0-9]+)'\W+ELSEIF\W+DB\t'([A-Z 0-9]+)'\W+ENDC\W+;.*\W+.*\W+SETDPOS\t9[*]32[+]6\W+DB\t'([A-Z]+)'";
			var colMatches = Regex.Matches(assemblySourceCode, kStagePattern);
			var c = colMatches.Count;

			for (int i = 0; i < c; i++) {
				AddStage(japanese, english, german, colMatches, i, true);
			}
			return Regex.Replace(assemblySourceCode, kStagePattern, "$1\tSETDPOS\t7*32+6\n\t$1_level\n\tSETDPOS\t9*32+6\n\t$1_stage");
		}

		private static string ExtractSectors(string assemblySourceCode,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german)
		{
			const string kSectorPattern = @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z 0-9]+)'\W+ELSEIF\W+DB\t'([A-Z 0-9]+)'\W+ENDC\W+;.*\W+.*\W+SETDPOS\t9[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z #$%]+)'\W+ELSEIF\W+DB\t'([A-Z #$%]+)'";
			var colMatches = Regex.Matches(assemblySourceCode, kSectorPattern);
			var c = colMatches.Count;

			for (int i = 0; i < c; i++) {
				AddStage(japanese, english, german, colMatches, i, false);
			}
			return Regex.Replace(assemblySourceCode, kSectorPattern, "$1\tSETDPOS\t7*32+6\n\t$1_level\n\tSETDPOS\t9*32+6\n\t$1_stage");
		}

		private static string ExtractArmada(string assemblySourceCode,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german)
		{
			const string kArmadaPattern = @"([a-z0-9]+)\tSETDPOS\t7[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z 0-9]+)'\W+ELSEIF\W+DB\t'([A-Z 0-9]+)'\W+ENDC\W+;.*\W+.*\W+SETDPOS\t9[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z #$%]+)'\W+ELSEIF\W+DB\t'([A-Z #$%-]+)'\W+ENDC\W+SETDPOS\t11[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t'([A-Z]+)'\W+ELSEIF\W+DB\t'([A-Z]+)'";
			var colMatches = Regex.Matches(assemblySourceCode, kArmadaPattern);
			var c = colMatches.Count;

			for (int i = 0; i < c; i++) {
				var match = AddStage(japanese, english, german, colMatches, i, false);
				var strLabel = match[1].Value;
				var strArmada = match[6].Value;

				japanese.Add(strLabel + "_stage2", strArmada);
				english.Add(strLabel + "_stage2", strArmada);
				german.Add(strLabel + "_stage2", match[7].Value);
			}
			return Regex.Replace(assemblySourceCode, kArmadaPattern, "$1\tSETDPOS\t7*32+6\n\t$1_level\n\tSETDPOS\t9*32+6\n\t$1_stage\n\tSETDPOS\t11*32+6\n\t$1_stage2");
		}

		private static GroupCollection AddStage(Dictionary<string, string> japanese, Dictionary<string, string> english,
		Dictionary<string, string> german, MatchCollection colMatches, int i, bool germanSharesStage)
		{
			var match = colMatches[i].Groups;
			var strLabel = match[1].Value;
			var strRoute = match[2].Value;
			var strStage = match[4].Value;

			Add(japanese, strLabel, strRoute, strStage);
			Add(english, strLabel, strRoute, strStage);
			Add(german, strLabel, match[3].Value, germanSharesStage ? strStage : match[5].Value);

			return match;
		}

		private static string ExtractBosses(string assemblySourceCode,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german)
		{
			const string kBossPattern = @"([A-Za-z0-9]+)\W+SETDPOS\t25[*]32[+]6\W+DB\t""([A-Z -]+)""\W+SETDPOS\t26[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z -]+)""\W+ELSEIF\W+DB\t""([A-Z -]+)""\W+ENDC\W+SETDPOS\t27[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z0-9 *-]+)""\W+ELSEIF\W+DB\t""([A-Z0-9 *-]+)""";
			var colMatches = Regex.Matches(assemblySourceCode, kBossPattern);
			var c = colMatches.Count;

			for (int i = 0; i < c; i++) {
				var match = colMatches[i].Groups;
				var strLabel = match[1].Value;
				var strName = match[2].Value;
				var strWeapon = match[3].Value;
				var strSize = match[5].Value;

				Add(japanese, strLabel, strName, strWeapon, strSize);
				Add(english, strLabel, strName, strWeapon, strSize);
				Add(german, strLabel, strName, match[4].Value, match[6].Value);
			}
			return Regex.Replace(assemblySourceCode, kBossPattern, "$1\tSETDPOS\t25*32+6\n\t$1_name\n\tSETDPOS\t26*32+6\n\t$1_weapon\n\tSETDPOS\t27*32+6\n\t$1_size");
		}

		private static string ExtractAndross(string assemblySourceCode,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german)
		{
			const string kAndrossPattern = @"([A-Za-z0-9]+)\tSETDPOS\t25[*]32[+]6\W+ifne\tJAPANESE\W+DB\t""([A-Z .-]+)""\W+elseif\W+DB\t""([A-Z .-]+)""\W+endc\W+SETDPOS\t26[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z -]+)""\W+ELSEIF\W+DB\t""([A-Z -]+)""\W+ENDC\W+SETDPOS\t27[*]32[+]6\W+IFEQ\tGERMAN\W+DB\t""([A-Z0-9 *-]+)""\W+ELSEIF\W+DB\t""([A-Z0-9 *-]+)""";
			var colMatches = Regex.Matches(assemblySourceCode, kAndrossPattern);
			var c = colMatches.Count;

			for (int i = 0; i < c; i++) {
				var match = colMatches[i].Groups;
				var strLabel = match[1].Value;
				var strName = match[3].Value;
				var strWeapon = match[4].Value;
				var strSize = match[6].Value;

				Add(japanese, strLabel, match[2].Value, strWeapon, strSize);
				Add(english, strLabel, strName, strWeapon, strSize);
				Add(german, strLabel, strName, match[5].Value, match[7].Value);
			}
			return Regex.Replace(assemblySourceCode, kAndrossPattern, "$1\tSETDPOS\t25*32+6\n\t$1_name\n\tSETDPOS\t26*32+6\n\t$1_weapon\n\tSETDPOS\t27*32+6\n\t$1_size");
		}

		private static void Add(Dictionary<string, string> destination, string label,
		string name, string weapon, string size)
		{
			destination.Add(label + "_name", name);
			destination.Add(label + "_weapon", weapon);
			destination.Add(label + "_size", size);
		}

		private static void Add(Dictionary<string, string> destination, string label, string level, string stage)
		{
			destination.Add(label + "_level", level);
			destination.Add(label + "_stage", stage);
		}

		private static void OutputDictionary(TextWriter writer,
		Dictionary<string, string> japanese, Dictionary<string, string> english, Dictionary<string, string> german,
		Dictionary<string, string> french, Dictionary<string, string> spanish)
		{
			writer.Write("\t; Character set of this file is ");
			writer.Write(writer.Encoding.WebName);
			writer.WriteLine(".");
			writer.WriteLine();

			writer.WriteLine("bt MACRO");
			writer.WriteLine("\tdb\t'\\1'");
			writer.WriteLine("\tENDM");
			writer.WriteLine();

			OutputDictionary(writer, "GERMAN", german);
			OutputDictionary(writer, "FRENCH", french);
			OutputDictionary(writer, "JAPANESE", japanese);
			OutputDictionary(writer, "SPANISH", spanish);
			OutputDictionary(writer, english);
		}

		private static void OutputDictionary(TextWriter writer, string language, Dictionary<string, string> dictionary)
		{
			writer.Write("\tIFNE\t");
			writer.WriteLine(language);
			CommonOutputDictionary(writer, dictionary);
		}

		private static void OutputDictionary(TextWriter writer, Dictionary<string, string> dictionary)
		{
			writer.WriteLine("\tIFEQ\tGERMAN+FRENCH+JAPANESE+SPANISH");
			CommonOutputDictionary(writer, dictionary);
		}

		private static void CommonOutputDictionary(TextWriter writer, Dictionary<string, string> dictionary)
		{
			foreach (var kvp in dictionary) {
				writer.Write(kvp.Key);
				writer.Write("\tbt\t<");
				writer.Write(kvp.Value);
				writer.WriteLine(">");
			}
			writer.WriteLine("\tENDC");
			writer.WriteLine();
		}
	}
}
