function bench_draw_settings_light_source()
{
	tab_control_togglebutton()
	togglebutton_add("type/point_light", icons.LIGHT_POINT, e_tl_type.POINT_LIGHT, bench_settings.light_type = e_tl_type.POINT_LIGHT, action_bench_light_type)
	togglebutton_add("type/spot_light", icons.LIGHT_SPOT, e_tl_type.SPOT_LIGHT, bench_settings.light_type = e_tl_type.SPOT_LIGHT, action_bench_light_type)
	draw_togglebutton("bench/light_type", dx, dy)
	tab_next()
	
	dy += 8

	if (bench_settings.light_type = e_tl_type.POINT_LIGHT)
		draw_tooltip_label("bench/point_light_tip", icons.INFO, e_toast.INFO)
	else
		draw_tooltip_label("bench/spot_light_tip", icons.INFO, e_toast.INFO)
}
