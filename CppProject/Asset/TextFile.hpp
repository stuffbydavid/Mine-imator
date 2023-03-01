#pragma once
#include "Asset.hpp"

namespace CppProject
{
	// Opened text file asset
	struct TextFile : Asset
	{
		TextFile(QFile* file, bool read);
		~TextFile();

		StringType ReadLine();
		StringType ReadWord();
		bool IsEof() const;

		QFile* file = nullptr;
		QTextStream* stream = nullptr;
		QStringList lines;
		QStringList lineWords;
		IntType currentLine = 0;
		IntType currentWord = 0;
	};
}