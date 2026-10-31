#pragma once
#include "Common.hpp"

#include <QDataStream>

namespace CppProject
{
	// Read interleaved array elements from byte planes.
	BoolType ReadShuffledArray(QDataStream& stream, void* target, IntType count, IntType stride);

	// Write corresponding array bytes together for compression.
	void WriteShuffledArray(QDataStream& stream, const void* source, IntType count, IntType stride);

	struct Gzip
	{
		// Write gzip-compressed bytes atomically.
		static void WriteCompressed(const QByteArray& data, const QString& filename, int compressionLevel = -1);

		// Start a gzip write tracked by the app.
		static void WriteAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel = -1);

		// Decompress a gzip file into a byte array.
		static BoolType Decompress(const QString& src, QByteArray& dst);

		// Decompress a gzip file into another file.
		static BoolType Decompress(const QString& src, const QString& dst);

		// Inflate zlib-compressed bytes into a byte array.
		static BoolType Decompress(const char* src, IntType size, QByteArray& dst);

		// Compress a byte array into a gzip file.
		static BoolType Compress(const QByteArray& src, const QString& dst);
	};

	struct Zstd
	{
		// Write a Zstd frame atomically with cancellation between input chunks.
		static void WriteCompressed(const QByteArray& data, const QString& filename, int compressionLevel = 3);

		// Start a compressed write tracked by the app.
		static void WriteAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel = 3);

		// Read a Zstd frame with a known decompressed size.
		static BoolType Decompress(const QString& filename, QByteArray& dst);
	};
}
