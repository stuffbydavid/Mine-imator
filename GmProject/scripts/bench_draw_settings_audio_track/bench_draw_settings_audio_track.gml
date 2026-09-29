function bench_draw_settings_audio_track()
{
	draw_sprite(spr_bench_example, 2, examplex, dy)
	dy += 144 + 15

	draw_tooltip_label("benchaudiotracktip", icons.INFO, e_toast.INFO)
}
