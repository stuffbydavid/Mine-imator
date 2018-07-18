/// app_event_step()

textbox_input = keyboard_string
keyboard_string = ""

app_update_window()

if (window_state = "load_assets")
	return 0

app_update_mouse()

if (window_state = "new_assets" || window_state = "export_movie")
	return 0

// Restore noise surface if gone
if (!surface_exists(noise_surf))
{
	noise_surf = surface_create(sprite_get_width(spr_noise), sprite_get_height(spr_noise))
	surface_set_target(noise_surf)
	{
		draw_sprite(spr_noise, 0, 0, 0)
	}
	surface_reset_target()
}

app_update_keyboard()
app_update_play()
app_update_animate()
app_update_previews()
app_update_backup()
app_update_recent()
app_update_work_camera()
app_update_caption()
current_step += 60 / room_speed
