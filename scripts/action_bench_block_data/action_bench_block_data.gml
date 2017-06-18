/// action_bench_block_data(value, add)
/// @arg value
/// @arg add

var data = argument1 * bench_settings.block_data + argument0

with (bench_settings)
{
	if (block_data = data) 
		return 0
	block_data = data
	temp_update_block()
}

bench_settings.preview.update = true
