#include "CppGen.hpp"

namespace CppGen
{
Sprite::Sprite(String dir, String outputFolder)
{
	DirectoryInfo dirInfo = DirectoryInfo(dir);
	this->name = dirInfo.name;

	String json = File::readAllText(dir + "/" + dirInfo.name + ".yy");
	Json root = JsonConvert::deserializeObject(json);

	this->originX = root["sequence"]["xorigin"];
	this->originY = root["sequence"]["yorigin"];

	for (Json frameObj : root["frames"])
	{
		String frameName = frameObj["name"];
		FileInfo srcImg = FileInfo(dir + "/" + frameName + ".png");
		FileInfo dstImg = FileInfo(outputFolder + "/" + this->name + "_frame_" + this->numFrames + ".png");
		if (!dstImg.exists || srcImg.lastWriteTime > dstImg.lastWriteTime)
		{
			srcImg.copyTo(dstImg.fullName, true);
			Sprite::totalCopied++;
		}
		this->numFrames++;
	}
}

}
