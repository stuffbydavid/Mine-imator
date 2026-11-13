function action_bench_light_type(type)
{
	if (bench_settings.light_type = type)
	{
		action_bench_create()
		bench_show_ani_type = "hide"
		return 0
	}
	
	if (!history_undo && !history_redo)
		history_set_var(action_bench_light_type, bench_settings.light_type, type, true)
	
	bench_settings.light_type = type
}
