/// action_background_volumetric_rays_emissive(color)
/// @arg color

var col;

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_volumetric_rays_emissive, true)
		tl_value_set(e_value.BG_VOLUMETRIC_RAYS_EMISSIVE, col, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_volumetric_rays_emissive, background_volumetric_rays_emissive, col, true)
}
	
background_volumetric_rays_emissive = col
