/// action_setting_block_subsurface(val, add)
/// @arg val
/// @arg add

function action_setting_block_subsurface(val, add)
{
	setting_block_subsurface = setting_block_subsurface * add + val
	render_samples = -1
}
