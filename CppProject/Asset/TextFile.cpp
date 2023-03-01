#include "TextFile.hpp"
#include "Type/StringType.hpp"

namespace CppProject
{
	TextFile::TextFile(QFile* file, bool read) : Asset(ID_TextFile)
	{
		this->file = file;
		stream = new QTextStream(file);

		if (read)
		{
			StringType text = stream->readAll();
			lines = text.Split('\n');
			lineWords = lines[0].split(" ");
			currentLine = currentWord = 0;
		}
	}

	TextFile::~TextFile()
	{
		deleteAndReset(stream);
		deleteAndReset(file);
	}

	StringType TextFile::ReadLine()
	{
		if (IsEof())
			return "";

		StringType line = lines[currentLine++];
		lineWords = line.Split(' ');
		currentWord = 0;
		return line;
	}

	StringType TextFile::ReadWord()
	{
		if (currentWord >= lineWords.size())
			return "";

		return lineWords[currentWord++];
	}

	bool TextFile::IsEof() const
	{
		return (currentLine >= lines.size());
	}
}