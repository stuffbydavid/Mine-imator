/// debug_info_draw()

if (!debug_info)
	return 0
	
var str = "";
str += "fps: " + string(fps) + " \n"
str += "fps_real: " + string(fps_real) + " \n"
str += "delta: " + string(delta) + " \n"
str += "DPI: " + string(display_get_dpi_x()) + "," + string(display_get_dpi_y()) + " \n"
str += "project_file: " + project_file + " \n"
str += "project_folder: " + project_folder + " \n"
str += "working_directory: " + working_directory + " \n"
str += "file_directory: " + file_directory + " \n"
str += "current_step: " + string(current_step) + " \n"
str += "instance_count: " + string(instance_count) + " \n"

content_x = 0
content_y = 0
content_width = window_width
content_height = window_height
draw_label(str, window_width - 7, window_height - 7, fa_right, fa_bottom, c_black, 1)
draw_label(str, window_width - 8, window_height - 8, fa_right, fa_bottom, c_yellow, 1)
