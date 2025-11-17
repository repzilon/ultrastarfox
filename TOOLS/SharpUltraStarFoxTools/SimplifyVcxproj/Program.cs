using System;
using System.Collections.Generic;
using System.IO;

namespace UltraStarFox.Tools.SimplifyVcxproj
{
	internal static class Program
	{
		private static long totalOriginalSize;
		private static long totalOptimizedSize;
		private static long totalFiles;

		private static void Main(string[] args)
		{
#pragma warning disable U2U1017 // Initialized locals should be used
			var dtmStart = DateTime.UtcNow;
#pragma warning restore U2U1017 // Initialized locals should be used
			var blnRecursive = false;

			var strWorkDir = Directory.GetCurrentDirectory();
			if ((args == null) || (args.Length < 1) || (args[0].Length < 1)) {
				ProcessDirectory(strWorkDir, blnRecursive);
			} else {
				var c = 0;
				for (var i = 0; i < args.Length; i++) {
					var argi = args[i];
					if ((argi == "-R") || (argi == "/R") || (argi == "--recursive")) {
						blnRecursive = true;
					} else if (File.Exists(argi)) {
						SimplifyProject(argi, "");
						c++;
					} else if (Directory.Exists(argi)) {
						ProcessDirectory(argi, blnRecursive);
						c++;
					} else {
						Console.Error.WriteLine(argi + " does not exist.");
					}
				}
				if (c < 1) {
					ProcessDirectory(strWorkDir, blnRecursive);
				}
			}
			if (totalOriginalSize > 0) {
				Console.WriteLine("{0,11} {1,10} {2,3}% TOTAL for {3} files in {4}", totalOriginalSize, totalOptimizedSize,
				 ComputePercentage(totalOriginalSize, totalOptimizedSize), totalFiles, DateTime.UtcNow - dtmStart);
			}

			Console.WriteLine("Press the Enter key to exit...");
			Console.ReadLine();
		}

		private static void ProcessDirectory(string folder, bool recursive)
		{
			var lstProj = FindProjects(folder, recursive);
			var c = lstProj.Count;
			for (var j = 0; j < c; j++) {
				SimplifyProject(lstProj[j], folder);
			}
		}

		private static void SimplifyProject(string inputPath, string directory)
		{
			var tskClean = ProjectSimplifier.ForProject(inputPath);
			if (tskClean != null) {
				var lngOrigSize = new FileInfo(inputPath).Length;
				try {
					tskClean.Run();
					var lngNewSize = new FileInfo(inputPath).Length;

					totalOriginalSize += lngOrigSize;
					totalOptimizedSize += lngNewSize;
					totalFiles++;
					Console.WriteLine("{0,11} {1,10} {2,3}% {3}", lngOrigSize, lngNewSize,
					 ComputePercentage(lngOrigSize, lngNewSize), RelativePath(inputPath, directory));
				} catch (Exception ex) {
					Console.WriteLine("{0,11} {1,10} {2,3}% {3}", lngOrigSize, "FAILED",
					 "XXX", RelativePath(inputPath, directory));
					Console.Error.WriteLine(ex.ToString());
				}
			}
		}

		private static List<string> FindProjects(string directory, bool recursive)
		{
			var enuSearch = recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly;
			var lstProjs = new List<string>(Directory.GetFiles(directory, "*.vcxproj", enuSearch));
			lstProjs.Sort();
			lstProjs.TrimExcess();
			return lstProjs;
		}

		private static byte ComputePercentage(long originalSize, long newSize)
		{
			var bytPercent = (byte)Math.Round(newSize * 100.0 / (originalSize * 1.0));
			if (bytPercent == 100) {
				if (newSize < originalSize) {
					bytPercent = 99;
				} else if (newSize > originalSize) {
					bytPercent = 101;
				}
			}
			return bytPercent;
		}

		private static string RelativePath(string fullPath, string basePath)
		{
			return String.IsNullOrEmpty(basePath) ? fullPath : fullPath.Replace(basePath, ".");
		}
	}
}