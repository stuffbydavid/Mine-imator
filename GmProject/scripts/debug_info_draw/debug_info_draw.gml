/// debug_info_draw()

function debug_info_draw()
{
	if (debug_info <= 0)
		return 0
	
	content_x = 0
	content_y = 0
	content_width = window_width
	content_height = window_height
	
	// Debug info
	var str = "";
	
	if (debug_info == 1)
	{
		str += "[F12] | FPS: " + string(fps) + " (" + string(fps_real) + ")"
	}
	else
	{
		str += "Performance: \n"
		str += "======================================= \n"
		str += "FPS: " + string(fps) + " \n"
		str += "FPS real: " + string(fps_real) + " \n"
		str += "delta: " + string(delta) + " \n"
		str += "\n"
		
		str += "Window: \n"
		str += "======================================= \n"
		str += "DPI: " + string(display_get_dpi_x()) + "," + string(display_get_dpi_y()) + " \n"
		str += "Size: " + string(window_width) + "," + string(window_height) + " \n"
		str += "window_busy: " + string(window_busy) + " \n"
		str += "window_focus: " + string(window_focus) + " \n"
		str += "current_step: " + string(current_step) + " \n"
		str += "\n"
		
		str += "Project: \n"
		str += "======================================= \n"
		str += "project_file: " + string_replace_all(project_file, "/", "\\") + " \n"
		str += "project_folder: " + string_replace_all(project_folder, "/", "\\") + " \n"
		str += "working_directory: " + string_replace_all(working_directory, "/", "\\") + " \n"
		str += "file_directory: " + string_replace_all(file_directory, "/", "\\") + " \n"
		str += "\n"
		
		str += "instance_count: " + string(instance_count) + " \n"
		str += "render_world() calls: " + string(render_world_count) + " \n"
		str += "Vertex buffer triangles: " + string(get_vertex_buffer_triangles()) + " \n"
		str += "Vertex buffer render calls: " + string(get_vertex_buffer_render_calls()) + " \n"
		str += "Primitive lines: " + string(get_primitive_lines()) + " \n"
		str += "Primitive triangles: " + string(get_primitive_triangles()) + " \n"
		str += "Primitive render calls: " + string(get_primitive_render_calls()) + " \n"
		str += "\n"
		
		if (dev_mode)
		{
			if (!is_cpp() && ds_list_size(window_list) > 0) // Debug windows in GM
			{
				str += "[F1]: Main view" + " \n"
				for (var i = 0; i < ds_list_size(window_list); i++)
				{
					var winindex = "undefined view";
					if (window_list[|i] = 1)
						winindex = "Secondary view"
					else if (window_list[|i] = 2)
						winindex = "Timeline view"
					str += "[F" + string(i + 2) + "]: " + winindex + " \n"
				}
				str += "\n"
			}
			str += "[F7]: Reload Minecraft assets" + " \n"
			str += "[F9]: Open file directory" + " \n"
			str += "[F10]: Open working directory" + " \n"
			str += "[F11]: Open log file" + " \n"
		}
		str += "[F12 to disable]"
	}
	
	var w = string_width_font(str, font_label) + 16;
	var h = string_height_font(str, font_label) + 16;
	var xx = debug_info_corner mod 2 == 0 ? 8 : window_width - w - 8;
	var yy = debug_info_corner < 2 ? 8 : window_height - h - 8;
	var tx = xx + 8;
	var ty = yy + h - 8;
	var mouseon = app_mouse_box(xx, yy, w, h);
	
	draw_box(xx, yy, w, h, false, c_black, mouseon ? .375 : .75) //window_width - w - 8
	draw_label(str, tx, ty, fa_left, fa_bottom, c_white, mouseon ? .5 : 1, font_label)
}
