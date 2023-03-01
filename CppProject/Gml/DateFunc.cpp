#include "Generated/GmlFunc.hpp"

#include <QDate>
#include <QTime>
#include <QLocale>

namespace CppProject
{
	QDateTime GmDateTimeToQ(RealType time)
	{
		QDateTime newTime = QDateTime(QDate(1899, 12, 30), QTime(0, 0, 0), Qt::UTC);
		newTime = newTime.addDays(std::floor(time));
		newTime = newTime.addMSecs(86400000.0 * (time - std::floor(time)));

		// Convert to local time
		newTime = newTime.toLocalTime();

		return newTime;
	}

	RealType date_current_datetime()
	{
		// GameMaker datatime formatted with days since 1899 December 30th, followed by day %. UTC
		QDateTime dateTimeStart = QDateTime(QDate(1899, 12, 30), QTime(0, 0, 0), Qt::UTC);
		QDateTime currentTime = QDateTime::currentDateTimeUtc();
		
		IntType days = dateTimeStart.daysTo(currentTime);
		RealType dayProgress = currentTime.time().msecsSinceStartOfDay() / 86400000.0;

		return days + dayProgress;
	}

	RealType date_day_span(RealType start, RealType end)
	{
		return end - start;
	}

	RealType date_get_day(RealType time)
	{
		return GmDateTimeToQ(time).date().day();
	}

	RealType date_get_month(RealType time)
	{
		return GmDateTimeToQ(time).date().month();
	}

	RealType date_get_week(RealType time)
	{
		return GmDateTimeToQ(time).date().weekNumber();
	}

	RealType date_get_year(RealType time)
	{
		return GmDateTimeToQ(time).date().year();
	}

	RealType date_hour_span(RealType start, RealType end)
	{
		return (end - start) * 24.0;
	}

	RealType date_minute_span(RealType start, RealType end)
	{
		return (end - start) * 1440.0;
	}

	RealType date_second_span(RealType start, RealType end)
	{
		return (end - start) * 86400.0;
	}

	StringType date_time_string(RealType time)
	{
		static QLocale localFormat;
		return GmDateTimeToQ(time).toString(localFormat.timeFormat(QLocale::LongFormat));
	}

	RealType date_week_span(RealType start, RealType end)
	{
		return (end - start) / 7;
	}
}