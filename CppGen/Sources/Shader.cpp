#include "CppGen.hpp"

namespace CppGen
{
Shader::Shader(String dir, String outputFolder)
{
	DirectoryInfo dirInfo = DirectoryInfo(dir);
	this->name = dirInfo.name;

	FileInfo srcVs = FileInfo(dir + "/" + this->name + ".vsh");
	FileInfo srcFs = FileInfo(dir + "/" + this->name + ".fsh");
	if (!srcVs.exists || !srcFs.exists)
		return;

	// Copy VS
	FileInfo dstVs = FileInfo(outputFolder + "/" + this->name + ".vsh");
	if (!dstVs.exists || srcVs.lastWriteTime > dstVs.lastWriteTime)
	{
		srcVs.copyTo(dstVs.fullName, true);
		Shader::totalCopied++;
	}
	else if (dstVs.lastWriteTime > srcVs.lastWriteTime)
	{
		String vsCodeDst = File::readAllText(dstVs.fullName);
		String vsCodeSrc = File::readAllText(srcVs.fullName);
		if (vsCodeDst != vsCodeSrc)
			Shader::modifications.add(makeObject<FileModification>(dstVs.fullName, srcVs.fullName));
	}

	// Copy FS
	FileInfo dstFs = FileInfo(outputFolder + "/" + this->name + ".fsh");
	if (!dstFs.exists || srcFs.lastWriteTime > dstFs.lastWriteTime)
	{
		srcFs.copyTo(dstFs.fullName, true);
		Shader::totalCopied++;
	}
	else if (dstFs.lastWriteTime > srcFs.lastWriteTime)
	{
		String fsCodeDst = File::readAllText(dstFs.fullName);
		String fsCodeSrc = File::readAllText(srcFs.fullName);
		if (fsCodeDst != fsCodeSrc)
			Shader::modifications.add(makeObject<FileModification>(dstFs.fullName, srcFs.fullName));
	}

	this->isValid = true;
}

Shader::FileModification::FileModification(String source, String dest)
{
	this->source = source;
	this->dest = dest;
}

}
