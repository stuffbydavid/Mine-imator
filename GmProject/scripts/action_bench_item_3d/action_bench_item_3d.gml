function action_bench_item_3d(enabled)
{
	with (bench_settings)
	{
		item_3d = enabled
		render_generate_item()
	}
	
	bench_settings.preview.update = true
}
