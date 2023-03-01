/// debug_info_draw()

function debug_info_draw()
{
	if (!debug_info)
		return 0
	
	var str = "DEBUG INFO:\n";
	str += "fps: " + string(fps) + " \n"
	str += "fps_real: " + string(fps_real) + " \n"
	str += "delta: " + string(delta) + " \n"
	str += "DPI: " + string(display_get_dpi_x()) + "," + string(display_get_dpi_y()) + " \n"
	str += "instance_count: " + string(instance_count) + " \n"
	str += "render_world() calls: " + string(render_world_count) + " \n"
	str += "Vertex buffer triangles: " + string(get_vertex_buffer_triangles()) + " \n"
	str += "Vertex buffer render calls: " + string(get_vertex_buffer_render_calls()) + " \n"
	str += "Primitive lines: " + string(get_primitive_lines()) + " \n"
	str += "Primitive triangles: " + string(get_primitive_triangles()) + " \n"
	str += "Primitive render calls: " + string(get_primitive_render_calls()) + " \n"
	str += "[F12 to disable]"
	
	content_x = 0
	content_y = 0
	content_width = window_width
	content_height = window_height
	draw_label(str, window_width - 7, window_height - 7, fa_right, fa_bottom, c_black, 1, font_value)
	draw_label(str, window_width - 8, window_height - 8, fa_right, fa_bottom, c_yellow, 1, font_value)
}
