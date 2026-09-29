function bench_draw_settings_camera_effects()
{
	bench_create_disabled = true

	draw_sprite(spr_bench_example, 5, examplex, dy)
	dy += 144 + 15

	draw_tooltip_label("benchcameraeffectstip", icons.INFO, e_toast.INFO)
}
