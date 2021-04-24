/// action_setting_texture_filtering_level(value, add)
/// @arg value
/// @arg add

function action_setting_texture_filtering_level(val, add)
{
	setting_texture_filtering_level = setting_texture_filtering_level * add + val
	render_samples = -1

	texture_set_mipmap_level(setting_texture_filtering_level)
}
