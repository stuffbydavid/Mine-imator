#include "GZIP.hpp"
#include "Heap.hpp"

#include <zlib.h>

namespace CppProject
{
	BoolType Gzip::Decompress(const QString& filename, QByteArray& dst)
	{
	#if OS_WINDOWS
		gzFile gzIn = gzopen_w(filename.toStdWString().c_str(), "rb8");
	#else
		gzFile gzIn = gzopen(filename.toStdString().c_str(), "rb8");
	#endif
		if (!gzIn)
		{
			WARNING("gzopen failed");
			return false;
		}

		while (true)
		{
			const IntType bufferSize = 1024;
			IntType offset = dst.size();
			dst.resize(dst.size() + bufferSize);
			int bytesRead = gzread(gzIn, dst.data() + offset, bufferSize);
			if (bytesRead < bufferSize)
			{
				dst.resize(offset + bytesRead);
				break;
			}
		}
		gzclose(gzIn);
		return true;
	}

	BoolType Gzip::Decompress(const QString& src, const QString& dst)
	{
		QFile file(dst);
		AddPerms(file);
		if (!file.open(QFile::WriteOnly))
		{
			WARNING("Could not decompress file " + src + ": " + file.errorString());
			return false;
		}

	#if OS_WINDOWS
		gzFile gzIn = gzopen_w(src.toStdWString().c_str(), "rb8");
	#else
		gzFile gzIn = gzopen(src.toStdString().c_str(), "rb8");
	#endif
		if (!gzIn)
		{
			WARNING("gzopen failed");
			return false;
		}
		char buf[1024];
		while (int len = gzread(gzIn, buf, sizeof(buf)))
			file.write(buf, len);

		gzclose(gzIn);
		return true;
	}

	BoolType Gzip::Decompress(const char* src, IntType size, QByteArray& dst)
	{
		dst.resize(size);

		z_stream strm;
		strm.next_in = (Bytef*)src;
		strm.avail_in = size;
		strm.total_out = 0;
		strm.zalloc = Z_NULL;
		strm.zfree = Z_NULL;

		if (inflateInit(&strm) != Z_OK)
			return false;

		while (true)
		{
			if (strm.total_out >= (IntType)dst.size())
				dst.resize(dst.size() + dst.size() / 2);

			strm.next_out = (Bytef*)(dst.data() + strm.total_out);
			strm.avail_out = dst.size() - strm.total_out;

			int err = inflate(&strm, Z_SYNC_FLUSH);
			if (err == Z_STREAM_END)
				break;
			else if (err != Z_OK)
				return false;
		}

		if (inflateEnd(&strm) != Z_OK)
			return false;

		dst.resize(strm.total_out);
		return true;
	}

	BoolType Gzip::Compress(const QByteArray& src, const QString& dst)
	{
	#if OS_WINDOWS
		gzFile gzOut = gzopen_w(dst.toStdWString().c_str(), "wb8");
	#else
		gzFile gzOut = gzopen(dst.toStdString().c_str(), "wb8");
	#endif
		if (!gzOut)
		{
			WARNING("gzopen failed");
			return false;
		}
		gzwrite(gzOut, src.data(), src.size());
		gzclose(gzOut);
		return true;
	}
}
