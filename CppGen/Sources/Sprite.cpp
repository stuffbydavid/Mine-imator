#include "CppGen.hpp"

namespace CppGen
{
Sprite::Sprite(String dir)
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
		this->frameNames.add(frameName);
		this->numFrames++;
	}
}

}
