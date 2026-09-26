#include "Generated/Scripts.hpp"

namespace CppProject
{
	StringType log_file_get()
	{
#if OS_WINDOWS
		return data_directory + "/log.txt";
#else
		return QDir::homePath() + "/Mine-imator/log.txt";
#endif
	}

	void Printer::Line(QString text)
	{
		QFile file(log_file_get());
		AddPerms(file);
		if (!file.open(QFile::Append))
			return;

		int ind = indent;
		while (ind--)
			text.insert(0, "   ");

		static QLocale localFormat;
		text.insert(0, QDateTime::currentDateTime().toString(localFormat.timeFormat(QLocale::LongFormat)) + " ");

		QTextStream stream(&file);
		stream << text << "\n";

	#if !RELEASE_MODE
		std::cout << text.toStdString() << std::endl;
	#endif
	}

	void Printer::Warning(QString text)
	{
		Printer::Line("[WARNING] " + text);
	}

	void Printer::Fatal(QString text)
	{
		Printer::Line("[FATAL ERROR] " + text);
		throw text;
	}

	RealType Random::Get(RealType max)
	{
		ThreadData& data = threadData[omp_get_thread_num()];
		return data.dist(data.gen) * max;
	}

	void Random::Set(IntType seed)
	{
		ThreadData& data = threadData[omp_get_thread_num()];
		data.seed = seed;
		data.gen = std::mt19937(data.seed);
	}

	uint16_t Random::GetSeed()
	{
		ThreadData& data = threadData[omp_get_thread_num()];
		return data.seed;
	}
}