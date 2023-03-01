#pragma once

#include "Common.hpp"

namespace CppProject
{
	struct Gzip
	{
		// Decompress a file using GZIP and stores the result in the given byte array, returning whether successful.
		static BoolType Decompress(const QString& src, QByteArray& dst);

		// Decompress a file using GZIP and stores the result in the given file, returning whether successful.
		static BoolType Decompress(const QString& src, const QString& dst);

		// Decompress bytes using GZIP and stores the uncompressed data in the given byte array, returning whether successful.
		static BoolType Decompress(const char* src, IntType size, QByteArray& dst);

		// Compress a byte array using GZIP and stores the result in the given file, returning whether successful.
		static BoolType Compress(const QByteArray& src, const QString& dst);
	};
}