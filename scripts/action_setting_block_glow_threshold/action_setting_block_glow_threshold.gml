/// action_setting_block_glow_threshold(value, add)
/// @arg value
/// @arg add

function action_setting_block_glow_threshold(val, add)
{
	setting_block_glow_threshold = setting_block_glow_threshold * add + val / 100
}
