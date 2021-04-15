/// rotation_get_time(rotation)
/// @arg rotation
/// @desc Returns time of day string

var totalminutes, day, hours, minutes, str;
totalminutes = (argument0 / 360) * (60 * 24) // Convert to total minutes in a day

hours = (floor(totalminutes / 60))
minutes = floor(totalminutes - (hours * 60))

hours += 12

day = floor(hours/24)
hours = mod_fix(hours, 24)

// Add days
str = (day != 0 ? string(day) + ":" : "")

// Add hours
str += ((day != 0 && hours < 10) ? "0" : "") + string(hours) + ":"

// Add minutes
str += ((minutes < 10 ? "0" : "") + string(minutes))

return str