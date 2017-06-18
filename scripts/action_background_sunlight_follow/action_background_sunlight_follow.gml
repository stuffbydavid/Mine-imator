/// action_background_sunlight_follow(follow)
/// @arg follow

var follow;

if (history_undo)
	follow = history_data.oldval
else if (history_redo)
	follow = history_data.newval
else
{
	follow = argument0
	history_set_var(action_background_sunlight_follow, background_sunlight_follow, follow, false)
}
	
background_sunlight_follow = follow
