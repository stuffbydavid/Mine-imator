/// action_tl_move_done(parent, position)
/// @arg parent
/// @arg position

var par, pos;
par = argument0
pos = argument1

if (par = null)
{
	par = app
	pos = null
}

action_tl_parent(par, pos)

with (timeline_move_obj)
	instance_destroy()
timeline_move_obj = null

window_busy = ""
