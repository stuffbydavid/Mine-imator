/// @desc Returns a string telling how long ago a project was last opened.

function recent_time_string(time)
{
	var currenttime = date_current_datetime();
	
	// Never opened
	if (time < 1)
		return text_get("recent/last_opened/never")
	
	var seconds, minutes, hours, days, weeks;
	seconds = date_second_span(time, currenttime)
	minutes = date_minute_span(time, currenttime)
	hours = date_hour_span(time, currenttime)
	days = date_day_span(time, currenttime)
	weeks = date_week_span(time, currenttime)
	
	// The future.. somehow
	if (currenttime < time)
		return text_get("recent/last_opened/future")
	
	// Last week
	if ((date_get_week(currenttime) != date_get_week(time)) && weeks < 2)
		return text_get("recent/last_opened/last_week")
	
	// Yesterday
	if ((date_get_day(currenttime) != date_get_day(time)) && hours < 24)
		return text_get("recent/last_opened/yesterday")
	
	// Opened recently
	if (minutes < 1)
		return text_get("recent/last_opened/recently")
	
	// Minutes
	if (minutes < 60)
		return text_get("recent/last_opened/minutes", floor(minutes))
	
	// Hours
	if (hours < 24)
		return text_get("recent/last_opened/hours", floor(hours))
	
	// Days
	if (days < 7)
		return text_get("recent/last_opened/days", floor(days))
	
	// Date
	return text_get("recent/last_opened/date", date_get_day(time), date_get_month(time), date_get_year(time))
}
