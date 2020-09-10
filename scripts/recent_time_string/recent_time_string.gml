/// recent_time_string(time)
/// @arg time
/// @desc Returns a string telling how long ago a model was last opened

var time, currenttime;
time = argument0
currenttime = date_current_datetime()

// Never opened
if (time < 1)
	return text_get("recentlastopenednever")
	
var seconds, minutes, hours, days, weeks;
seconds = date_second_span(time, currenttime)
minutes = date_minute_span(time, currenttime)
hours = date_hour_span(time, currenttime)
days = date_day_span(time, currenttime)
weeks = date_week_span(time, currenttime)

// The future.. somehow
if (currenttime < time)
	return text_get("recentlastopenedfuture")

// Last week
if ((date_get_week(currenttime) != date_get_week(time)) && weeks < 2)
	return text_get("recentlastopenedlastweek")

// Yesterday
if ((date_get_day(currenttime) != date_get_day(time)) && hours < 24)
	return text_get("recentlastopenedyesterday")

// Opened recently
if (minutes < 1)
	return text_get("recentlastopenedrecently")

// Minutes
if (minutes < 60)
	return text_get("recentlastopenedminutes", floor(minutes))

// Hours
if (hours < 24)
	return text_get("recentlastopenedhours", floor(hours))

// Days
if (days < 7)
	return text_get("recentlastopeneddays", floor(days))

// Date
return text_get("recentlastopeneddate", date_get_day(time), date_get_month(time), date_get_year(time))