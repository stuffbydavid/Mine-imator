/// action_background_diffuse_boost(diffuse_boost)
/// @arg diffuse_boost

var diffuse_boost;

if (history_undo)
	diffuse_boost = history_data.old_value
else if (history_redo)
	diffuse_boost = history_data.new_value
else
{
	diffuse_boost = argument0
	history_set_var(action_background_diffuse_boost, background_diffuse_boost, diffuse_boost, false)
}
	
background_diffuse_boost = diffuse_boost
