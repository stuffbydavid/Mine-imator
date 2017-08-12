/// action_bench_block_name(block)
/// @arg block
/// @desc Sets the block name of the workbench settings.

with (bench_settings)
{
	if (block_name = argument0)
		return 0
		
	block_name = argument0
	temp_update_block_state()
	temp_update_block()
}

bench_settings.preview.update = true
