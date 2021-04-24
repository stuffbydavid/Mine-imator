/// action_setting_block_brightness(value, add)
/// @arg value
/// @arg add

function action_setting_block_brightness(val, add)
{
	setting_block_brightness = setting_block_brightness * add + val / 100
	render_samples = -1
}
