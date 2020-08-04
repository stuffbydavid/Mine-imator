/// action_background_volumetric_fog_noise_scale(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_volumetric_fog_noise_scale, true)
		tl_value_set(e_value.BG_VOLUMETRIC_FOG_NOISE_SCALE, val, add)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_volumetric_fog_noise_scale, background_volumetric_fog_noise_scale, background_volumetric_fog_noise_scale * add + val, true)
}

background_volumetric_fog_noise_scale = background_volumetric_fog_noise_scale * add + val
