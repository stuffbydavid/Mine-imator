#include "Generated/Scripts.hpp"
#include "World/GZIP.hpp"

#include <QDesktopServices>
#include <QTextStream>
#include <QUrl>

#define ZIP_STATIC
#include <zip.h>

namespace CppProject
{
	RealType lib_open_url(StringType url)
	{
		if (!url.StartsWith("http"))
			url = "file:///" + url;
		return QDesktopServices::openUrl((QString)url);
	}

	RealType lib_execute(StringType file, StringType param, RealType wait)
	{
		return 0.0;
	}

	RealType lib_unzip(StringType src, StringType dst)
	{
		int err;
		std::string srcStd = src.ToStdString();
		struct zip* za = zip_open(srcStd.c_str(), 0, &err);
		if (!za)
		{
			WARNING("Could not unzip " + src);
			return -1;
		}

		IntType numEntries = zip_get_num_entries(za, 0);
		IntType files = 0, numFiles = numEntries;
		for (int i = 0; i < numEntries; i++)
		{
			struct zip_stat sb;
			if (zip_stat_index(za, i, 0, &sb))
			{
				WARNING("Could not extract file " + StringType(sb.name));
				continue;
			}

			QString fileName = dst + sb.name;
			QFileInfo info(fileName);
			if (fileName.endsWith("/")) // Skip directories
			{
				numFiles--;
				continue;
			}

			// Create path of directories to file if needed
			if (!QDir(info.path()).exists())
				if (!QDir().mkpath(info.path()))
					WARNING("Could not create path " + info.path());

			// Open destination file for writing
			struct zip_file* zf = zip_fopen_index(za, i, 0);
			QFile file(fileName);
			AddPerms(file);

			if (!zf || !file.open(QFile::WriteOnly))
			{
				WARNING("Could not extract file " + QString(sb.name) + ": " + file.errorString());
				continue;
			}

			int sum = 0;
			bool readErr = false;
			while (sum != sb.size)
			{
				char buf[1024];
				int readNum = zip_fread(zf, buf, sizeof(buf));
				if (readNum < 0)
				{
					WARNING("Could not extract file " + StringType(sb.name));
					readErr = true;
					break;
				}
				if (file.write(buf, readNum) < 0)
				{
					WARNING("Could not extract file " + StringType(sb.name));
					readErr = true;
					break;
				}
				sum += readNum;
			}

			zip_fclose(zf);
			if (!readErr)
				files++;
		}

		if (zip_close(za) < 0)
			return -1;
		
		DEBUG("Extracted " + NumStr(files) + "/" + NumStr(numFiles) + " files");
		return files == numFiles;
	}

	RealType lib_gzunzip(StringType src, StringType dst)
	{
		Gzip::Decompress(src, dst);
		return 0;
	}

	RealType lib_file_rename(StringType src, StringType dst)
	{
		QDir srcDir(src);
		if (srcDir.exists()) // Directory rename
		{
			QDir dstDir(dst);
			if (dstDir.exists() && !dstDir.removeRecursively())
				WARNING("Could not remove directory " + dst);

			BoolType ok = srcDir.rename(src, dst);
			if (!ok)
				WARNING("Could not rename directory " + src);

			return ok;
		}

		// File rename
		QFile srcFile(src);
		if (!srcFile.exists())
			return false;

		QFile dstFile(dst);
		if (dstFile.exists())
		{
			AddPerms(dstFile);
			if (!dstFile.remove())
				WARNING("Could not delete file " + dst.QStr() + ": " + dstFile.errorString());
		}

		AddPerms(srcFile);
		BoolType ok = srcFile.rename(dst);
		if (!ok)
			WARNING("Could not rename file " + src.QStr() + ": " + srcFile.errorString());
		return ok;
	}

	RealType lib_file_copy(StringType src, StringType dst)
	{
		QFile srcFile(src);
		if (!srcFile.exists())
			return false;

		QFile dstFile(dst);
		if (dstFile.exists())
		{
			AddPerms(dstFile);
			if (!dstFile.remove(dst))
				WARNING("Could not delete file " + dst.QStr() + ": " + srcFile.errorString());
		}

		AddPerms(srcFile);
		BoolType ok = srcFile.copy(dst);
		if (!ok)
			WARNING("Could not copy file " + src.QStr() + ": " + srcFile.errorString());
		return ok;
	}

	RealType lib_file_delete(StringType fn)
	{
		QFile file(fn);
		if (!file.exists())
			return false;

		AddPerms(file);
		BoolType ok = file.remove();
		if (!ok)
			WARNING("Could not delete file " + fn.QStr() + ": " + file.errorString());
		return ok;
	}

	RealType lib_file_exists(StringType file)
	{
		return QFile::exists(file);
	}

	RealType lib_directory_create(StringType dir)
	{
		BoolType ok = QDir().mkpath(dir);
		if (!ok)
			WARNING("Could not create directory " + dir);
		return ok;
	}

	RealType lib_directory_delete(StringType dir)
	{
		BoolType ok = QDir(dir).removeRecursively();
		if (!ok)
			WARNING("Could not delete directory " + dir);
		return ok;
	}

	RealType lib_directory_exists(StringType dir)
	{
		return QDir(dir).exists();
	}

	RealType lib_json_file_convert_unicode(StringType src, StringType dst)
	{
		return lib_file_copy(src, dst);
	}
}