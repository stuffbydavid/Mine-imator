#include "GZIP.hpp"
#include "AppHandler.hpp"
#include "Heap.hpp"

#include <QSaveFile>

#include <zlib.h>

namespace CppProject
{
	struct GzipWrite
	{
		QString filename, label, error;
		BoolType reported = false, cancelled = false;
		double elapsed = 0;

		void Report()
		{
			if (reported || cancelled)
				return;

			reported = true;

			if (!error.isEmpty())
				WARNING("Could not save " + label + " " + filename + ": " + error);
			else
				DEBUG(label + " compress/write: " + NumStr(elapsed) + "s (" + filename + ")");
		}
	};

	void Gzip::WriteCompressed(const QByteArray& data, const QString& filename, int compressionLevel)
	{
		QThread* thread = QThread::currentThread();
		if (thread->isInterruptionRequested())
			return;

		// Replace the destination only after the complete gzip stream is written
		QSaveFile file(filename);
		if (!file.open(QIODevice::WriteOnly))
			throw file.errorString();

		z_stream gzip = {};
		if (deflateInit2(&gzip, compressionLevel, Z_DEFLATED, MAX_WBITS + 16, 8, Z_DEFAULT_STRATEGY) != Z_OK)
			throw QString("Could not initialize gzip compression");

		gzip.next_in = reinterpret_cast<Bytef*>(const_cast<char*>(data.constData()));

		char buffer[65536];
		int remaining = data.size();
		int result;
		do
		{
			if (thread->isInterruptionRequested())
			{
				deflateEnd(&gzip);
				return;
			}

			// Limit input as well as output so compressible data can be cancelled promptly
			if (!gzip.avail_in)
			{
				gzip.avail_in = std::min(remaining, (int)sizeof(buffer));
				remaining -= gzip.avail_in;
			}

			gzip.next_out = reinterpret_cast<Bytef*>(buffer);
			gzip.avail_out = sizeof(buffer);

			result = deflate(&gzip, remaining ? Z_NO_FLUSH : Z_FINISH);
			if (result != Z_OK && result != Z_STREAM_END)
			{
				deflateEnd(&gzip);
				throw QString("Could not compress resource data");
			}

			qint64 size = sizeof(buffer) - gzip.avail_out;
			if (file.write(buffer, size) != size)
			{
				deflateEnd(&gzip);
				throw file.errorString();
			}
		}
		while (result != Z_STREAM_END);

		deflateEnd(&gzip);

		if (thread->isInterruptionRequested())
			return;

		if (!file.commit())
			throw file.errorString();
	}

	void Gzip::WriteAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel)
	{
		QString path = QFileInfo(filename).absoluteFilePath();
		QString threadName = "gzip:" + path;

		// Cancel earlier writes and wait only for their current chunk and cleanup
		for (QThread* thread : App->threads)
		{
			if (thread->objectName() == threadName)
			{
				thread->requestInterruption();
				thread->wait();
			}
		}

		// Only bytes and Qt strings cross the worker boundary
		auto job = std::make_shared<GzipWrite>();
		job->filename = path;
		job->label = label;

		QThread* thread = QThread::create([job, data = std::move(data), compressionLevel]() mutable
		{
			try
			{
				Timer tmr;
				WriteCompressed(data, job->filename, compressionLevel);
				job->elapsed = tmr.Elapsed();
			}
			catch (const QString& error)
			{
				job->error = error;
			}

			job->cancelled = QThread::currentThread()->isInterruptionRequested();
			data.clear();
		});

		// Report on the main thread, including when shutdown has stopped the event loop
		auto report = [job] { job->Report(); };
		QObject::connect(thread, &QThread::finished, App, report, Qt::QueuedConnection);
		QObject::connect(thread, &QObject::destroyed, App, report);

		thread->setObjectName(threadName);
		App->threads.append(thread);
		thread->start();
	}

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

		char buffer[65536];
		while (true)
		{
			int bytesRead = gzread(gzIn, buffer, sizeof(buffer));
			if (bytesRead < 0 || bytesRead > std::numeric_limits<int>::max() - dst.size())
			{
				gzclose(gzIn);
				return false;
			}

			if (!bytesRead)
				break;

			dst.append(buffer, bytesRead);
		}

		return gzclose(gzIn) == Z_OK;
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

		char buffer[65536];
		while (true)
		{
			int bytesRead = gzread(gzIn, buffer, sizeof(buffer));
			if (bytesRead < 0 || (bytesRead > 0 && file.write(buffer, bytesRead) != bytesRead))
			{
				gzclose(gzIn);
				return false;
			}

			if (!bytesRead)
				break;
		}

		return gzclose(gzIn) == Z_OK;
	}

	BoolType Gzip::Decompress(const char* src, IntType size, QByteArray& dst)
	{
		if (size <= 0 || size > std::numeric_limits<int>::max())
			return false;

		dst.resize(int(size));

		z_stream strm = {};
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
			{
				IntType nextSize = std::min(IntType(std::numeric_limits<int>::max()), IntType(dst.size()) + std::max(IntType(1), IntType(dst.size()) / 2));
				if (nextSize <= dst.size())
				{
					inflateEnd(&strm);
					return false;
				}

				dst.resize(int(nextSize));
			}

			strm.next_out = (Bytef*)(dst.data() + strm.total_out);
			strm.avail_out = dst.size() - strm.total_out;

			int err = inflate(&strm, Z_SYNC_FLUSH);
			if (err == Z_STREAM_END)
				break;
			else if (err != Z_OK)
			{
				inflateEnd(&strm);
				return false;
			}
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
