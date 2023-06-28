/// action_bench_model_blend_color(col)

function action_bench_model_blend_color(col)
{
	with (bench_settings)
	{
		model_blend_color = col
		
		with (preview)
			update = true
	}
}