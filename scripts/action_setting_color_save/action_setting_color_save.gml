/// action_setting_color_save()

var fn = file_dialog_save_color("");

if (fn = "")
	return 0

fn = filename_new_ext(fn, ".mcolor")

buffer_current = buffer_create(8, buffer_grow, 1)
settings_write_colors()
buffer_export(buffer_current, fn)
buffer_delete(buffer_current)
