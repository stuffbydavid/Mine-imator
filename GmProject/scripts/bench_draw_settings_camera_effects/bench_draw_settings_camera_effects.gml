function bench_draw_settings_camera_effects()
{
	var list = setting_advanced_mode ? bench_settings.camera_effect_list_advanced : bench_settings.camera_effect_list_simple;
	if (ds_list_find_index(list.list, bench_settings.camera_effect_type) < 0)
	{
		bench_settings.camera_effect_type = e_cam_fx.FADE
		list.scroll.value = 0
		list.scroll.value_goal = 0
	}
	
	dy -= 8
	
	tab_control(bench_list_height(list))
	sortlist_draw(list, dx, dy, dw, tab_control_h, bench_settings.camera_effect_type, false, text_get("bench/effect"))
	tab_next()
	
	dy += 4
	
	var effectname = camera_effect_name_list[|bench_settings.camera_effect_type];
	var tipname = "frame_editor/camera_effect/" + effectname + "/tip";
	if (bench_settings.camera_effect_type = e_cam_fx.FADE)
		tipname = "frame_editor/camera_effect/fade_tip"
	draw_tooltip_label(tipname, icons.INFO, e_toast.INFO)
}
