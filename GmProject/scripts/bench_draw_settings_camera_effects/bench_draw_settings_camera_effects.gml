function bench_draw_settings_camera_effects()
{
	dy -= 8
	
	// Effect list
	var list = setting_advanced_mode ? bench_settings.camera_effect_list_advanced : bench_settings.camera_effect_list_simple;
	if (ds_list_find_index(list.list, bench_settings.camera_effect_type) < 0)
	{
		bench_settings.camera_effect_type = e_cam_fx.FADE
		list.scroll.value = 0
		list.scroll.value_goal = 0
	}
	
	tab_control(bench_list_height(list))
	sortlist_draw(list, dx, dy, dw, tab_control_h, bench_settings.camera_effect_type, false, text_get("bench/effect"))
	tab_next()

	// Camera
	if (bench_settings.camera_effect_camera != app &&
		(!instance_exists(bench_settings.camera_effect_camera) || bench_settings.camera_effect_camera.type != e_tl_type.CAMERA))
		bench_settings.camera_effect_camera = app

	tab_control_menu()
	draw_button_menu("bench/camera", e_menu.LIST, dx, dy, dw, 24, bench_settings.camera_effect_camera,
		bench_settings.camera_effect_camera = app ? text_get("bench/all_cameras") : bench_settings.camera_effect_camera.display_name,
		action_bench_camera_effect_camera)
	tab_next()
	
	dy += 8
	
	// Effect tip
	var tipname = "frame_editor/camera_effect/" + camera_effect_name_list[|bench_settings.camera_effect_type] + "/tip";
	if (bench_settings.camera_effect_type = e_cam_fx.FADE)
		tipname = "frame_editor/camera_effect/fade_tip"
	draw_tooltip_label(tipname, icons.INFO, e_toast.INFO)
}
