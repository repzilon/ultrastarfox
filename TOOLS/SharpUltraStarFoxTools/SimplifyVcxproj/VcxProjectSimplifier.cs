using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

namespace UltraStarFox.Tools.SimplifyVcxproj
{
	internal sealed class VcxProjectSimplifier : ProjectSimplifier
	{
		internal const string XmlNamespace = "http://schemas.microsoft.com/developer/msbuild/2003";

		public VcxProjectSimplifier(string filePath, XmlDocument loaded) : base(filePath, loaded) { }

		private void CollapseEmptyTextElements()
		{
			var strXml = File.ReadAllText(this.ProjectFilePath);
			var strNewXml = Regex.Replace(strXml, @"<([A-Za-z]+)>\W+?</([A-Za-z]+)>", "<$1></$2>");
			strNewXml = Regex.Replace(strNewXml, @"<([A-Za-z]+) Include=""(.+?)"">\W+?</([A-Za-z]+)>", "<$1 Include=\"$2\" />");
			//strNewXml = strNewXml.Trim() + Environment.NewLine;
			if (strNewXml != strXml) {
				File.WriteAllText(this.ProjectFilePath, strNewXml, Encoding.UTF8);
			}
		}

		private static void RemoveQueuedElements(List<XmlElement> wasteBasket)
		{
			var c = wasteBasket.Count;
			for (var i = 0; i < c; i++) {
				var elmToRemove = wasteBasket[i];
				if (elmToRemove.ParentNode != null) {
					elmToRemove.ParentNode.RemoveChild(elmToRemove);
				}
			}
		}

		public override void Run()
		{
			var xnlPropGroup = this.XmlDocument.GetElementsByTagName("PropertyGroup", XmlNamespace);
			var lstToRemove = new List<XmlElement>();
			// Classify non-empty property groups
			var                 c                  = xnlPropGroup.Count;
			var                 dicGroupsByHeaders = new Dictionary<string, List<XmlElement>>(c);
			int                 i;
			XmlElement          elmPropGroup, elmProperty;
			string              strHeader;
			PropertyGroupHeader pgh;
			for (i = 0; i < c; i++) {
				elmPropGroup = (XmlElement)xnlPropGroup[i];
				if (elmPropGroup.HasChildNodes) {
					strHeader = new PropertyGroupHeader(elmPropGroup).ToString();
					if (dicGroupsByHeaders.ContainsKey(strHeader)) {
						dicGroupsByHeaders[strHeader].Add(elmPropGroup);
					} else {
						dicGroupsByHeaders.Add(strHeader, new List<XmlElement> { elmPropGroup });
					}
				} else {
					lstToRemove.Add(elmPropGroup);
				}
			}

			// Find for which configurations the same property and value is set
			var dicConfigsByProperty = new Dictionary<string, KeyValuePair<List<XmlElement>, List<PropertyGroupHeader>>>();
			foreach (var x in dicGroupsByHeaders.Values) {
				c = x.Count;
				for (i = 0; i < c; i++) {
					pgh = new PropertyGroupHeader(x[i]);
					foreach (XmlNode xn in x[i].ChildNodes) {
						elmProperty = xn as XmlElement;
						if (elmProperty != null) {
							var strOuterXml = elmProperty.OuterXml;
							if (dicConfigsByProperty.ContainsKey(strOuterXml)) {
								var lstPgh = dicConfigsByProperty[strOuterXml].Value;
								if (lstPgh.FindIndex(y => y.ToString() == pgh.ToString()) < 0) {
									dicConfigsByProperty[strOuterXml].Key.Add(elmProperty);
									lstPgh.Add(pgh);
								}
							} else {
								dicConfigsByProperty.Add(strOuterXml,
									new KeyValuePair<List<XmlElement>, List<PropertyGroupHeader>>(
										new List<XmlElement> { elmProperty }, new List<PropertyGroupHeader> { pgh }));
							}
						}
					}
				}
			}

			// Find common configuration conditions of each property and value
			foreach (var kvp in dicConfigsByProperty) {
				var headers = kvp.Value.Value;
				if (headers.Count >= 2) {
					// Make new PropertyGroup if necessary, then move first element into it
					pgh = new PropertyGroupHeader(CommonValue(headers, x => x.Label),
						CommonValue(headers, x => x.Configuration), CommonValue(headers, x => x.Platform));
					strHeader   = pgh.ToString();
					elmProperty = kvp.Value.Key[0];
					if (!dicGroupsByHeaders.ContainsKey(strHeader)) {
						elmPropGroup = pgh.NewElement(this.XmlDocument);
						elmProperty.ParentNode.ParentNode.InsertBefore(elmPropGroup, elmProperty.ParentNode);
						dicGroupsByHeaders.Add(strHeader, new List<XmlElement> { elmPropGroup });
					} else if (dicGroupsByHeaders[strHeader].Count == 1) {
						elmPropGroup = dicGroupsByHeaders[strHeader][0];
					} else {
						throw new NotSupportedException();
					}
					elmPropGroup.AppendChild(elmProperty);

					// Remove other property elements
					c = kvp.Value.Key.Count;
					for (i = 1; i < c; i++) {
						elmProperty = kvp.Value.Key[i];
						elmProperty.ParentNode.RemoveChild(elmProperty);
					}
				}
			}

			// Scan again and exclude emptied property groups
			c = xnlPropGroup.Count;
			for (i = 0; i < c; i++) {
				elmPropGroup = (XmlElement)xnlPropGroup[i];
				if (!elmPropGroup.HasChildNodes) {
					lstToRemove.Add(elmPropGroup);
				}
			}

			RemoveQueuedElements(lstToRemove);
			this.SaveProject(false, true);
			this.CollapseEmptyTextElements();
		}

		private static string CommonValue(List<PropertyGroupHeader> headers, Func<PropertyGroupHeader, string> property)
		{
			var values = headers.Select(property).Distinct().ToArray();
			return values.Length == 1 ? values[0] : null;
		}
	}
}
