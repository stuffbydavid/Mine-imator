using Newtonsoft.Json;
using System.IO;

namespace CppGen
{
	class Sprite
	{
		public string Name;
		public int NumFrames = 0;
		public static int TotalCopied = 0;
		public int OriginX = 0;
		public int OriginY = 0;

		// Copies sprite frames to the CppProject.
		public Sprite(string dir, string outputFolder)
		{
			DirectoryInfo dirInfo = new DirectoryInfo(dir);
			Name = dirInfo.Name;

			string json = File.ReadAllText(dir + @"\" + dirInfo.Name + ".yy");
			dynamic root = JsonConvert.DeserializeObject(json);

			OriginX = root["sequence"]["xorigin"];
			OriginY = root["sequence"]["yorigin"];

			foreach (dynamic frameObj in root["frames"])
			{
				string frameName = frameObj["name"];
				FileInfo srcImg = new FileInfo(dir + @"\" + frameName + ".png");
				FileInfo dstImg = new FileInfo(outputFolder + @"\" + Name + "_frame_" + NumFrames + ".png");
				if (!dstImg.Exists || srcImg.LastWriteTime > dstImg.LastWriteTime)
				{
					srcImg.CopyTo(dstImg.FullName, true);
					TotalCopied++;
				}
				NumFrames++;
			}
		}
	}
}
