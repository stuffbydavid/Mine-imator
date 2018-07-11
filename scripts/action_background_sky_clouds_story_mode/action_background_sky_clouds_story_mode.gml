/// action_background_sky_clouds_story_mode(story_mode)
/// @arg flat

var story_mode;

if (history_undo)
	story_mode = history_data.old_value
else if (history_redo)
	story_mode = history_data.new_value
else
{
	story_mode = argument0
	history_set_var(action_background_sky_clouds_story_mode, background_sky_clouds_story_mode, story_mode, false)
}

background_sky_clouds_story_mode = story_mode
background_sky_update_clouds()
