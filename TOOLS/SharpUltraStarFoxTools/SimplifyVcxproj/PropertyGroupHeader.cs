using System;
using System.Text.RegularExpressions;
using System.Xml;

namespace UltraStarFox.Tools.SimplifyVcxproj
{
	internal sealed class PropertyGroupHeader
	{
		public string Configuration { get; }
		public string Platform { get; }
		public string Label { get; }

		public PropertyGroupHeader(string label, string configuration, string platform)
		{
			Label         = label;
			Configuration = configuration;
			Platform      = platform;
		}

		public PropertyGroupHeader(XmlElement from)
		{
			this.Label = from.GetAttribute("Label");
			var strCondition = from.GetAttribute("Condition");
			if (!String.IsNullOrEmpty(strCondition)) {
				var m = Regex.Match(strCondition,
					@"'\$\(Configuration\)\|\$\(Platform\)'=='([A-Za-z]+)\|([A-Za-z0-9]+)'");
				if (m.Success) {
					this.Configuration = m.Groups[1].Value;
					this.Platform      = m.Groups[2].Value;
				}
			}
		}

		public XmlElement NewElement(XmlDocument owner)
		{
			var    elmPropGroup = owner.CreateElement("PropertyGroup", VcxProjectSimplifier.XmlNamespace);
			string strCondition = null;
			if (!String.IsNullOrEmpty(this.Configuration) && !String.IsNullOrEmpty(this.Platform)) {
				strCondition = "'$(Configuration)|$(Platform)'=='" + this.Configuration + "|" + this.Platform + "'";
			} else if (!String.IsNullOrEmpty(this.Configuration)) {
				strCondition = "'$(Configuration)'=='" + this.Configuration + "'";
			} else if (!String.IsNullOrEmpty(this.Platform)) {
				strCondition = "'$(Platform)'=='" + this.Platform + "'";
			}

			if (!String.IsNullOrEmpty(strCondition)) {
				elmPropGroup.SetAttribute("Condition", strCondition);
			}
			if (!String.IsNullOrEmpty(this.Label)) {
				elmPropGroup.SetAttribute("Label", this.Label);
			}

			return elmPropGroup;
		}

		public override string ToString()
		{
			return String.Format("{2}:{0}|{1}", this.Configuration, this.Platform, this.Label);
		}

		public override int GetHashCode()
		{
			return this.ToString().GetHashCode();
		}
	}
}
