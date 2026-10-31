function action_bench_model_blend_color(color)
{
	with (bench_settings)
	{
		model_blend_color = color
		
		with (preview)
			update = true
	}
}
