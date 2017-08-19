/// debug_info_draw()

if (!debug_info)
	return 0
	
var str = "";
str += "project_file: " + project_file + " \n"
str += "project_folder: " + project_folder + " \n"
str += "working_directory: " + working_directory + " \n"
str += "file_directory: " + file_directory + " \n"
str += "fps_real: " + string(fps_real) + " \n"
str += "current_step: " + string(current_step) + " \n"
str += "instance_count: " + string(instance_count) + " \n"
str += "window_busy: " + window_busy + " \n"
str += "window_focus: " + window_focus + " \n"
if (popup)
	str += "popup.name: " + popup.name + " \n"
else
	str += "popup.name: \n"
str += "popup_ani_type: " + popup_ani_type + " \n"
str += "popup_mouseon: " + string(popup_mouseon) + " \n"
str += "delta: " + string(delta) + " \n"
str += "DPI: " + string(display_get_dpi_x()) + "," + string(display_get_dpi_y()) + " \n"

content_x = 0
content_y = 0
content_width = window_width
content_height = window_height
draw_label(str, window_width - 8, window_height - 8, fa_right, fa_bottom, c_yellow, 1)
