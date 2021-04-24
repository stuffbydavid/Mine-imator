/// scrollbar_event_create()
/// @desc Executed upon the creation of a scrollbar.

function scrollbar_event_create()
{
	snap_value = 0 // Amount of pixels to snap to
	value = 0
	value_goal = 0
	press = 0
	needed = false
	atend = false
	value_ease = true
	mouseon = false
	
	mousenear = false
	mousenear_prev = false
	mousenear_ani = 0
	mousenear_ani_ease = 0
	mousenear_base = 0
	mousenear_offset = 0
	mousenear_offset_ani = 0
	mousenear_offset_ani_ease = 0
}
