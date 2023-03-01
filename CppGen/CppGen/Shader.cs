using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace CppGen
{
	public class Shader
	{
		public string Name;
		public bool IsValid = false;
		public static int TotalCopied = 0;

		public class FileModification
		{
			public string Source;
			public string Dest;

			public FileModification(string source, string dest)
			{
				Source = source;
				Dest = dest;
			}
		}

		static public List<FileModification> Modifications = new List<FileModification>();

		// Copies GLSL ES shaders to the CppProject.
		public Shader(string dir, string outputFolder)
		{
			DirectoryInfo dirInfo = new DirectoryInfo(dir);
			Name = dirInfo.Name;

			FileInfo srcVs = new FileInfo(dir + @"\" + Name + ".vsh");
			FileInfo srcFs = new FileInfo(dir + @"\" + Name + ".fsh");
			if (!srcVs.Exists || !srcFs.Exists)
				return;

			// Copy VS
			FileInfo dstVs = new FileInfo(outputFolder + @"\" + Name + ".vsh");
			if (!dstVs.Exists || srcVs.LastWriteTime > dstVs.LastWriteTime)
			{
				srcVs.CopyTo(dstVs.FullName, true);
				TotalCopied++;
			}
			else if (dstVs.LastWriteTime > srcVs.LastWriteTime)
			{
				string vsCodeDst = File.ReadAllText(dstVs.FullName);
				string vsCodeSrc = File.ReadAllText(srcVs.FullName);
				if (vsCodeDst != vsCodeSrc)
					Modifications.Add(new FileModification(dstVs.FullName, srcVs.FullName));
			}

			// Copy FS
			FileInfo dstFs = new FileInfo(outputFolder + @"\" + Name + ".fsh");
			if (!dstFs.Exists || srcFs.LastWriteTime > dstFs.LastWriteTime)
			{
				srcFs.CopyTo(dstFs.FullName, true);
				TotalCopied++;
			}
			else if (dstFs.LastWriteTime > srcFs.LastWriteTime)
			{
				string fsCodeDst = File.ReadAllText(dstFs.FullName);
				string fsCodeSrc = File.ReadAllText(srcFs.FullName);
				if (fsCodeDst != fsCodeSrc)
					Modifications.Add(new FileModification(dstFs.FullName, srcFs.FullName));
			}

			IsValid = true;
		}
	}
}
