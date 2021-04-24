/// action_bench_item_slot(index)
/// @arg index

function action_bench_item_slot(index)
{
	with (bench_settings)
	{
		item_slot = index
		render_generate_item()
	}
	
	bench_settings.preview.update = true
}
