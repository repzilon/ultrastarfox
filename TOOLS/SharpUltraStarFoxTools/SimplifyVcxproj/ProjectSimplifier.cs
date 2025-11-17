using System;
using System.IO;
using System.Text;
using System.Xml;

namespace UltraStarFox.Tools.SimplifyVcxproj
{
	internal abstract class ProjectSimplifier
	{
		private string m_strFilePath;
		private XmlDocument m_docProject;

		protected ProjectSimplifier() { }

		protected ProjectSimplifier(string filePath, XmlDocument loaded)
		{
			m_strFilePath = filePath;
			m_docProject = loaded;
		}

		public string ProjectFilePath
		{
			get { return m_strFilePath; }
			set
			{
				if (value != m_strFilePath) {
					m_docProject = null;
					m_strFilePath = value;
				}
			}
		}

		public abstract void Run();

		protected XmlDocument XmlDocument
		{
			get
			{
				if ((m_docProject == null) && !String.IsNullOrEmpty(m_strFilePath) && File.Exists(m_strFilePath)) {
					m_docProject = LoadXmlFile(m_strFilePath);
				}
				return m_docProject;
			}
		}

		private static XmlDocument LoadXmlFile(string path)
		{
			var docForLoad = new XmlDocument();
#if (NETCOREAPP1_0)
			using (var smrXml = File.OpenText(path)) {
				docForLoad.Load(smrXml);
			}
#else
			docForLoad.Load(path);
#endif
			return docForLoad;
		}

		private static string Beautify(XmlDocument doc)
		{
			var sb = new StringBuilder();
			var settings = new XmlWriterSettings
			{
				Indent = true,
				IndentChars = "  ",
				NewLineChars = "\r\n",
				NewLineHandling = NewLineHandling.Replace
			};
			using (var writer = XmlWriter.Create(sb, settings)) {
				doc.Save(writer);
			}
			return sb.ToString();
		}

		protected void SaveProject(bool removeXmlEncoding, bool withBom)
		{
			var strIndented = Beautify(this.XmlDocument);
			strIndented = strIndented.Replace("utf-16", "utf-8");
			if (removeXmlEncoding) {
				strIndented = strIndented.Replace("<?xml version=\"1.0\" encoding=\"utf-8\"?>", "").Trim();
			}
			File.WriteAllText(this.ProjectFilePath, strIndented, new UTF8Encoding(withBom));
		}

		public static ProjectSimplifier ForProject(string filePath)
		{
			var docProject = LoadXmlFile(filePath);
			return docProject.DocumentElement.NamespaceURI == VcxProjectSimplifier.XmlNamespace ?
			 new VcxProjectSimplifier(filePath, docProject) : (ProjectSimplifier)null;
		}
	}
}
