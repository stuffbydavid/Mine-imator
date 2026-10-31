#include "Compress.hpp"
#include "AppHandler.hpp"
#include "Heap.hpp"

#include <QBuffer>
#include <QSaveFile>
#include <zlib.h>
#include <zstd.h>

namespace CppProject
{
	BoolType ReadShuffledArray(QDataStream& stream, void* target, IntType count, IntType stride)
	{
		if (stream.status() != QDataStream::Ok)
			return false;

		if (count < 0 || stride <= 0 || count > std::numeric_limits<int>::max() / stride)
		{
			stream.setStatus(QDataStream::ReadCorruptData);
			return false;
		}

		IntType size = count * stride;
		QByteArray data;
		const char* planes;
		QBuffer* buffer = qobject_cast<QBuffer*>(stream.device());
		if (buffer)
		{
			// Read directly from the cache without copying its byte planes
			qint64 pos = buffer->pos();
			if (!buffer->isReadable() || size > buffer->size() - pos || !buffer->seek(pos + size))
			{
				stream.setStatus(QDataStream::ReadPastEnd);
				return false;
			}

			planes = buffer->buffer().constData() + pos;
		}
		else
		{
			data.resize(int(size));
			if (stream.readRawData(data.data(), data.size()) != data.size())
				return false;

			planes = data.constData();
		}

		// Restore interleaved elements from their byte planes
		char* bytes = static_cast<char*>(target);
		for (IntType byte = 0; byte < stride; byte++)
			for (IntType i = 0; i < count; i++)
				bytes[i * stride + byte] = planes[byte * count + i];

		return true;
	}

	void WriteShuffledArray(QDataStream& stream, const void* source, IntType count, IntType stride)
	{
		if (stream.status() != QDataStream::Ok)
			return;

		if (count < 0 || stride <= 0 || count > std::numeric_limits<int>::max() / stride)
		{
			stream.setStatus(QDataStream::WriteFailed);
			return;
		}

		IntType size = count * stride;
		QByteArray data;
		char* planes;
		QBuffer* buffer = qobject_cast<QBuffer*>(stream.device());
		qint64 pos = buffer ? buffer->pos() : 0;
		if (buffer)
		{
			if (!buffer->isWritable() || size > std::numeric_limits<int>::max() - pos)
			{
				stream.setStatus(QDataStream::WriteFailed);
				return;
			}

			// Shuffle straight into the reserved cache array
			QByteArray& output = buffer->buffer();
			if (pos + size > output.size())
				output.resize(int(pos + size));

			planes = output.data() + pos;
		}
		else
		{
			data.resize(int(size));
			planes = data.data();
		}

		// Group corresponding bytes so repeated values compress together
		const char* bytes = static_cast<const char*>(source);
		for (IntType byte = 0; byte < stride; byte++)
			for (IntType i = 0; i < count; i++)
				planes[byte * count + i] = bytes[i * stride + byte];

		if (buffer)
		{
			if (!buffer->seek(pos + size))
				stream.setStatus(QDataStream::WriteFailed);
		}
		else
			stream.writeRawData(data.constData(), data.size());
	}

	using CompressionWriter = void (*)(const QByteArray&, const QString&, int);

	struct CompressedWrite
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

	static void WriteCompressedAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel, CompressionWriter writer)
	{
		QString path = QFileInfo(filename).absoluteFilePath();
		QString threadName = "compress:" + path;

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
		auto job = std::make_shared<CompressedWrite>();
		job->filename = path;
		job->label = label;

		QThread* thread = QThread::create([job, data = std::move(data), compressionLevel, writer]() mutable
		{
			try
			{
				Timer tmr;
				writer(data, job->filename, compressionLevel);
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
		WriteCompressedAsync(std::move(data), filename, label, compressionLevel, WriteCompressed);
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

	static size_t CheckZstd(size_t result)
	{
		if (ZSTD_isError(result))
			throw QString::fromUtf8(ZSTD_getErrorName(result));

		return result;
	}

	void Zstd::WriteCompressed(const QByteArray& data, const QString& filename, int compressionLevel)
	{
		QThread* thread = QThread::currentThread();
		if (thread->isInterruptionRequested())
			return;

		QSaveFile file(filename);
		if (!file.open(QIODevice::WriteOnly))
			throw file.errorString();

		std::unique_ptr<ZSTD_CCtx, decltype(&ZSTD_freeCCtx)> context(ZSTD_createCCtx(), ZSTD_freeCCtx);
		if (!context)
			throw QString("Could not initialize Zstd compression");

		CheckZstd(ZSTD_CCtx_setParameter(context.get(), ZSTD_c_compressionLevel, compressionLevel));
		CheckZstd(ZSTD_CCtx_setParameter(context.get(), ZSTD_c_checksumFlag, 1));
		CheckZstd(ZSTD_CCtx_setPledgedSrcSize(context.get(), data.size()));

		char buffer[65536];
		size_t offset = 0;
		do
		{
			size_t inputSize = std::min(size_t(sizeof(buffer)), size_t(data.size()) - offset);
			ZSTD_inBuffer input = { data.constData() + offset, inputSize, 0 };
			ZSTD_EndDirective directive = offset + inputSize == size_t(data.size()) ? ZSTD_e_end : ZSTD_e_continue;
			size_t remaining;
			do
			{
				if (thread->isInterruptionRequested())
					return;

				ZSTD_outBuffer output = { buffer, sizeof(buffer), 0 };
				remaining = CheckZstd(ZSTD_compressStream2(context.get(), &output, &input, directive));
				if (file.write(buffer, output.pos) != qint64(output.pos))
					throw file.errorString();
			}
			while (input.pos < input.size || (directive == ZSTD_e_end && remaining));

			offset += inputSize;
		}
		while (offset < size_t(data.size()));

		if (!thread->isInterruptionRequested() && !file.commit())
			throw file.errorString();
	}

	void Zstd::WriteAsync(QByteArray data, const QString& filename, const QString& label, int compressionLevel)
	{
		WriteCompressedAsync(std::move(data), filename, label, compressionLevel, WriteCompressed);
	}

	BoolType Zstd::Decompress(const QString& filename, QByteArray& dst)
	{
		QFile file(filename);
		if (!file.open(QIODevice::ReadOnly) || file.size() > std::numeric_limits<int>::max())
			return false;

		QByteArray data = file.readAll();
		if (data.size() != file.size())
			return false;

		unsigned long long size = ZSTD_getFrameContentSize(data.constData(), data.size());
		if (size > std::numeric_limits<int>::max())
			return false;

		// Reject incomplete frames and trailing data before allocating the output
		size_t frameBytes = ZSTD_findFrameCompressedSize(data.constData(), data.size());
		if (ZSTD_isError(frameBytes) || frameBytes != size_t(data.size()))
			return false;

		dst.resize(int(size));

		size_t result = ZSTD_decompress(dst.data(), dst.size(), data.constData(), data.size());
		return (!ZSTD_isError(result) && result == size);
	}
}
