function action_bench_shape_tex_map(enabled)
{
	with (bench_settings)
	{
		shape_tex_mapped = enabled
		temp_update_shape()
	}
	
	bench_settings.preview.update = true
}
