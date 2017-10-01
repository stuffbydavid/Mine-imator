/// app_event_step()

textbox_input = keyboard_string
keyboard_string = ""

app_update_window()

if (window_busy = "load_assets")
	return 0

app_update_mouse()
app_update_keyboard()

if (window_busy = "export_movie")
	return 0
	
app_update_play()
app_update_animate()
app_update_previews()
app_update_backup()
app_update_recent()
app_update_work_camera()
app_update_caption()
current_step += 60 / room_speed