/// @desc Executed upon the creation of a scrollbar.

function scrollbar_event_create()
{
	snap_value = 0 // Amount of pixels to snap to
	wheel_speed = 120
	
	value = 0
	value_goal = 0
	value_ease = true
	
	press = 0
	needed = false
	atend = false
	zoomable = false
	
	search = false
	search_tbx = new_textbox(true, 0, "")
	search_slots = null
	
	picker_tip_slot = -1
	picker_tip_time = 0
	
	mouseon = false
	mousenear = new value_animation()
}
