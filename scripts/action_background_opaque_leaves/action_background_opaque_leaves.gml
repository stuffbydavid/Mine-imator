/// action_background_opaque_leaves(opaque)
/// @arg opaque

var opaque;

if (history_undo)
	opaque = history_data.old_value
else if (history_redo)
	opaque = history_data.new_value
else
{
	opaque = argument0
	history_set_var(action_background_opaque_leaves, background_opaque_leaves, opaque, false)
}
	
background_opaque_leaves = opaque
alert_show(text_get("alertreloadprojecttitle"), text_get("alertreloadprojecttext"), null, "", "", 5000)
