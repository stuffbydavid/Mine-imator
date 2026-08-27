#include "CppGen.hpp"

namespace CppGen
{
Shader::Shader(String dir)
{
	DirectoryInfo dirInfo = DirectoryInfo(dir);
	this->name = dirInfo.name;

	FileInfo srcVs = FileInfo(dir + "/" + this->name + ".vsh");
	FileInfo srcFs = FileInfo(dir + "/" + this->name + ".fsh");
	if (!srcVs.exists || !srcFs.exists)
		return;

	this->isValid = true;
}

}
