/// action_bench_block_name(block)
/// @arg block
/// @desc Sets the block name of the workbench settings.

function action_bench_block_name(block)
{
	with (bench_settings)
	{
		if (block_name = block)
			return 0
		
		block_name = block
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		temp_update_block()
		
		preview.update = true
	}
}
