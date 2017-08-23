/// action_background_sunlight_follow(follow)
/// @arg follow

var follow;

if (history_undo)
	follow = history_data.old_value
else if (history_redo)
	follow = history_data.new_value
else
{
	follow = argument0
	history_set_var(action_background_sunlight_follow, background_sunlight_follow, follow, false)
}
	
background_sunlight_follow = follow
