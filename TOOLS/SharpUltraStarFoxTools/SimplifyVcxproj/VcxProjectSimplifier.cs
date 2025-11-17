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
			var xnlPropGroup =
				this.XmlDocument.GetElementsByTagName("PropertyGroup", XmlNamespace);
			var lstToRemove = new List<XmlElement>();
			// Classify non-empty property groups
			var c                  = xnlPropGroup.Count;
			var dicGroupsByHeaders = new Dictionary<string, List<XmlElement>>(c);
			int i;
			for (i = 0; i < c; i++) {
				var elmPropGroup = (XmlElement)xnlPropGroup[i];
				if (elmPropGroup.HasChildNodes) {
					var strHeader = new PropertyGroupHeader(elmPropGroup).ToString();
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
			var dicConfigsByProperty =
				new Dictionary<string, KeyValuePair<List<XmlElement>, List<PropertyGroupHeader>>>();
			foreach (var x in dicGroupsByHeaders.Values) {
				c = x.Count;
				for (i = 0; i < c; i++) {
					var pgh = new PropertyGroupHeader(x[i]);
					foreach (XmlNode xn in x[i].ChildNodes) {
						var xe = xn as XmlElement;
						if (xe != null) {
							var strOuterXml = xe.OuterXml;
							if (dicConfigsByProperty.ContainsKey(strOuterXml)) {
								var lstPgh = dicConfigsByProperty[strOuterXml].Value;
								if (lstPgh.FindIndex(y => y.ToString() == pgh.ToString()) < 0) {
									dicConfigsByProperty[strOuterXml].Key.Add(xe);
									lstPgh.Add(pgh);
								}
							} else {
								dicConfigsByProperty.Add(strOuterXml, 
									new KeyValuePair<List<XmlElement>, List<PropertyGroupHeader>>(
										new List<XmlElement> { xe }, new List<PropertyGroupHeader> { pgh }));
							}
						}
					}
				}
			}

			// Find common configuration conditions of each property and value
			foreach (var kvp in dicConfigsByProperty) {
				var headers = kvp.Value.Value;
				if (headers.Count >= 2) {
					var labels  = headers.Select(x => x.Label).Distinct().ToArray();
					var configs = headers.Select(x => x.Configuration).Distinct().ToArray();
					var cpus    = headers.Select(x => x.Platform).Distinct().ToArray();
					// Make new PropertyGroup if necessary, then move first element into it
					var pgh = new PropertyGroupHeader(labels.Length == 1 ? labels[0] : null,
						configs.Length == 1 ? configs[0] : null, cpus.Length == 1 ? cpus[0] : null);
					var strHeader = pgh.ToString();
					var xeProperty = kvp.Value.Key[0];
					XmlElement xeGroup = null;
					if (!dicGroupsByHeaders.ContainsKey(strHeader)) {
						xeGroup = pgh.NewElement(this.XmlDocument);
						xeProperty.ParentNode.ParentNode.InsertBefore(xeGroup, xeProperty.ParentNode);
						dicGroupsByHeaders.Add(strHeader, new List<XmlElement> { xeGroup });
					} else if (dicGroupsByHeaders[strHeader].Count == 1) {
						xeGroup = dicGroupsByHeaders[strHeader][0];
					} else {
						throw new NotSupportedException();
					}
					xeGroup.AppendChild(xeProperty);

					// Remove other property elements
					c = kvp.Value.Key.Count;
					for (i = 1; i < c; i++) {
						xeProperty = kvp.Value.Key[i];
						xeProperty.ParentNode.RemoveChild(xeProperty);
					}
				}
			}

			// Scan again and exclude emptied property groups
			c = xnlPropGroup.Count;
			for (i = 0; i < c; i++) {
				var elmPropGroup = (XmlElement)xnlPropGroup[i];
				if (!elmPropGroup.HasChildNodes) {
					lstToRemove.Add(elmPropGroup);
				}
			}

			RemoveQueuedElements(lstToRemove);
			this.SaveProject(false, true);
			this.CollapseEmptyTextElements();
		}
	}
}
