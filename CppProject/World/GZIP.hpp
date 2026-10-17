#pragma once

#include "Common.hpp"

namespace CppProject
{
	struct Gzip
	{
		// Write gzip-compressed bytes atomically.
		static void WriteCompressed(const QByteArray& data, const QString& filename, int compressionLevel = -1);

		// Start a compressed write tracked by the app, reporting failures on the main thread.
		static void WriteAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel = -1);

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
