/// action_bench_item_3d(enable)
/// @arg enable

function action_bench_item_3d(enable)
{
	with (bench_settings)
	{
		item_3d = enable
		render_generate_item()
	}
	
	bench_settings.preview.update = true
}
