/// @arg x
/// @arg y
/// @arg width
/// @arg height

function bench_draw_settings(bx, by, bw, bh)
{
	dx = bx
	dy = by
	dw = bw
	dh = bh
	content_x = dx
	content_y = dy
	content_width = dw
	content_height = dh
	
	var prevalpha, aniease, sy;
	prevalpha = draw_get_alpha()
	
	bench_settings_ani += test_reduced_motion(1, (0.09 * delta))
	bench_settings_ani = clamp(bench_settings_ani, 0, 1)
	
	aniease = ease("easeoutcirc", bench_settings_ani)
	draw_set_alpha(aniease * prevalpha)
	
	dx += -16 + (16 * aniease)
	examplex = floor(dx + (dw - sprite_get_width(spr_bench_example)) / 2)
	
	sy = dy
	
	// Preview
	if (array_contains(bench_tab_preview, bench_tab))
	{
		preview_draw(bench_settings.preview, dx, dy, dw, 144)
		dy += 144 + 8
	}
	
	menu_bench = true
	
	bench_buttons_hidden = false
	
	bench_create_disabled = false
	bench_create_name = "benchcreate"
	bench_create_icon = icons.ASSET_ADD
	bench_create_button = e_bench_button.CREATE
	
	bench_edit_hidden = true
	bench_edit_name = "benchedit"
	bench_edit_icon = icons.PENCIL
	bench_edit_button = e_bench_button.EDIT

	switch (bench_tab)
	{
		case e_bench_tab.PROJECT:			bench_draw_settings_project(); break
		case e_bench_tab.CHARACTER:
		case e_bench_tab.EQUIPMENT:
		case e_bench_tab.SPECIAL_BLOCK:
		case e_bench_tab.MODEL_PART:		bench_draw_settings_character(); break
		case e_bench_tab.MODEL:				bench_draw_settings_model(); break
		case e_bench_tab.ITEM:				bench_draw_settings_item(); break
		case e_bench_tab.WORLD:				bench_draw_settings_world(); break
		case e_bench_tab.SCHEMATIC:			bench_draw_settings_schematic(); break
		case e_bench_tab.BLOCK:				bench_draw_settings_block(); break
		case e_bench_tab.CAMERA:			bench_draw_settings_camera(); break
		case e_bench_tab.SOUND:				bench_draw_settings_sound(); break
		case e_bench_tab.AUDIO_TRACK:		bench_draw_settings_audio_track(); break
		case e_bench_tab.PARTICLE_SPAWNER:	bench_draw_settings_particle_spawner(); break
		case e_bench_tab.TEXT:				bench_draw_settings_text(); break
		case e_bench_tab.CAMERA_EFFECTS:	bench_draw_settings_camera_effects(); break
		case e_bench_tab.LIGHT_SOURCE:		bench_draw_settings_light_source(); break
		case e_bench_tab.PATH:				bench_draw_settings_path(); break
		case e_bench_tab.ENVIRONMENT:		bench_draw_settings_environment(); break
		case e_bench_tab.SHAPE:				bench_draw_settings_shape(); break
	}
	
	menu_bench = false
	
	draw_set_alpha(prevalpha)
	dx = bx
	
	dy += 36
	
	if (bench_buttons_hidden)
		return 0
	
	// Edit
	var wid = (bench_edit_hidden ? dw : dw/2 - 4);
	if (!bench_edit_hidden)
	{
		if (draw_button_label(bench_edit_name, dx, sy + dh - 56, wid, bench_edit_icon, e_button.SECONDARY, null, e_anchor.LEFT, bench_create_disabled))
		{
			action_bench_create(bench_edit_button)
			bench_show_ani_type = "hide"
		}
	}
	
	// Create
	if (draw_button_label(bench_create_name, bench_edit_hidden ? dx : (dx + wid + 8), sy + dh - 56, wid, bench_create_icon, e_button.PRIMARY, null, e_anchor.LEFT, bench_create_disabled))
	{
		action_bench_create(bench_create_button)
		bench_show_ani_type = "hide"
	}
}
