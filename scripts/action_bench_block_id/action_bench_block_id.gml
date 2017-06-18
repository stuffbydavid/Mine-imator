/// action_bench_block_id(block)
/// @arg block
/// @desc Sets the block id of the workbench settings.

with (bench_settings)
{
    if (block_id = argument0)
        return 0
    block_id = argument0
    temp_update_block()
}

bench_settings.preview.update = true
