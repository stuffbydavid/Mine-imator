/// app_event_step()

textbox_input = keyboard_string
keyboard_string = ""

app_update_caption()
app_update_window()
app_update_mouse()
app_update_keyboard()

if (!exportmovie)
{
    app_update_play()
    app_update_animate()
    app_update_previews()
    app_update_backup()
    app_update_recent()
    app_update_work_camera()
    
    current_step += 60 / room_speed
}
