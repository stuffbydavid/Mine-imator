function bench_draw_settings_light_source()
{
	draw_sprite(spr_bench_example, (bench_settings.light_type = e_tl_type.POINT_LIGHT) ? 0 : 1, examplex, dy)
	dy += 144 + 15

	tab_control_togglebutton()
	togglebutton_add("typepointlight", null, e_tl_type.POINT_LIGHT, bench_settings.light_type = e_tl_type.POINT_LIGHT, action_bench_light_type)
	togglebutton_add("typespotlight", null, e_tl_type.SPOT_LIGHT, bench_settings.light_type = e_tl_type.SPOT_LIGHT, action_bench_light_type)
	draw_togglebutton("benchlighttype", dx, dy)
	tab_next()
	dy += 4

	if (bench_settings.light_type = e_tl_type.POINT_LIGHT)
		draw_tooltip_label("benchpointlighttip", icons.LIGHT_POINT, e_toast.INFO)
	else
		draw_tooltip_label("benchspotlighttip", icons.LIGHT_SPOT, e_toast.INFO)
}
