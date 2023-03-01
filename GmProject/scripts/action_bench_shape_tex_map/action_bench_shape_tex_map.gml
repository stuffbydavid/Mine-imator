/// action_bench_shape_tex_map(enable)
/// @arg enable

function action_bench_shape_tex_map(enable)
{
	with (bench_settings)
	{
		shape_tex_mapped = enable
		temp_update_shape()
	}
	bench_settings.preview.update = true
}
