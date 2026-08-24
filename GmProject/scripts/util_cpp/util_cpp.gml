/// CppSeparate BoolType is_cpp()
function is_cpp()
{
	return false;
}

/// CppSeparate void log_message(StringType text)
function log_message(text)
{
	show_debug_message(text)
}

/// CppSeparate StringType os_get()
function os_get()
{
	return "Windows 11";
}

/// CppSeparate IntType platform_get()
function platform_get()
{
	return e_platform.WINDOWS;
}

/// CppSeparate RealType interface_scale_default_get()
/// Returns the default interface scaling factor.
function interface_scale_default_get()
{
	return 1	
}

/// CppSeparate void interface_scale_set(RealType)
/// Sets the interface scaling factor.
function interface_scale_set(factor)
{
}

/// CppSeparate StringType user_directory_get()
/// Returns the location where user generated files are written (log, key, settings, projects).
/// On Windows this is the Data folder in the installation, on Unix this is ~/Mine-imator
function user_directory_get()
{
	return working_directory + "Data/"
}

/// CppSeparate StringType projects_directory_get()
/// Returns the default location where projects are saved.
/// On Windows this is the Projects folder in the installation, on Unix this is ~/Mine-imator/Projects
function projects_directory_get()
{
	return working_directory + "Projects/"
}

/// CppSeparate StringType skins_directory_get()
/// Returns the location where downloaded player skins are saved.
/// On Windows this is the Skins folder in the installation, on Unix this is ~/Mine-imator/Skins
function skins_directory_get()
{
	return working_directory + "Skins/"
}

/// CppSeparate StringType drivers_url_get()
/// Returns an URL to an article showing how to update graphics drivers.
function drivers_url_get()
{
	return "https://www.thewindowsclub.com/how-to-update-graphics-drivers-windows"
}

/// Returns whether an array of filenames are accepted to be dropped on the window.
function window_drop_enter(files)
{
	if (window_busy != "")
		return false
	
	if (array_length(files) > 1) // TODO multifile support?
		return false
	
	return string_contains(asset_exts, "*" + filename_ext(files[0]) + ";")
}

/// Executes when a previously accepted filename is dropped on the window.
function window_drop(files)
{
	asset_load(files[0])
}

/// CppSeparate IntType window_get_current()
/// Returns the current window being rendered to as an e_window value.
function window_get_current()
{
	return window_debug_current;
}

/// CppSeparate void window_create(IntType, IntType, IntType, IntType, IntType)
/// Creates a new window from a rectangle relative to the current window.
function window_create(window, xx, yy, width, height)
{
	ds_list_add(window_list, window)
}

/// CppSeparate void window_close(IntType)
/// Closes a window with the given e_window value.
function window_close(window)
{
	window_event_closed(window)
}

/// Runs when a window is closed.
function window_event_closed(window)
{
	if (window_debug_current = window)
		window_debug_current = e_window.MAIN
	
	if (window = e_window.VIEW_SECOND)
		app.view_second.show = false
	if (window = e_window.TIMELINE)
		panel_tab_list_add(app.timeline.panel_last, 0, app.timeline)
	
	ds_list_delete_value(window_list, window)
}

/// Returns whether a window with the given e_window value has been created.
function window_exists(window)
{
	return (ds_list_find_index(window_list, window) >= 0)
}

/// CppSeparate BoolType window_mouse_is_active(IntType)
/// Returns whether the mouse is active on the given window.
function window_mouse_is_active(window)
{
	return true
}

/// CppSeparate void window_mouse_set_permission(BoolType)
/// Sets whether the mouse position is allowed to be set by the software.
function window_mouse_set_permission(enabled)
{
}

/// CppSeparate BoolType window_mouse_get_permission()
/// Returns whether the mouse position is allowed to be set by the software.
function window_mouse_get_permission()
{
	return true;
}

/// CppSeparate void window_state_save(IntType)
/// Saves the window state to the current JSON file.
function window_state_save(window)
{
}

/// CppSeparate void window_state_restore(IntType, IntType)
/// Restores a previously saved window state from the given JSON map.
function window_state_restore(window, map)
{
}

/// CppSeparate void window_main_restore(VarType, BoolType)
/// Restores the main window location.
function window_main_restore(rect, maximize)
{
	window_maximize()
}

/// CppSeparate void surface_clear_depth_cache(IntType)
/// Clears the previously cached depth from surface_get_depth calls.
function surface_clear_depth_cache(surf)
{
}

/// CppSeparate RealType surface_get_depth(IntType, IntType, IntType)
/// Returns the depth from 0-1 at a pixel in the surface, the result is cached between calls.
function surface_get_depth(surf, xx, yy)
{
	return 0.995
}

/// CppSeparate IntType surface_get_max_size()
/// Returns the maximum allowed width/height of a surface. Exceeding this will give undefined behavior.
function surface_get_max_size()
{
	return no_limit
}

/// CppSeparate BoolType res_load_scenery_world(Scope<obj_resource>)
/// Imports a box selection from a world and stores it in the resource.
/// Returns whether the world is available.
function res_load_scenery_world()
{
	show_debug_message("Import from " + world_regions_dir)
	return true
}

/// CppSeparate void res_save_block_cache(Scope<obj_resource>, StringType)
function res_save_block_cache(filename)
{
	ready = true
}

/// CppSeparate BoolType res_load_block_cache(Scope<obj_resource>, StringType)
function res_load_block_cache(filename)
{
	ready = true
	return false
}

/// CppSeparate IntType thread_get_number()
/// Returns the amount of total concurrent threads available (cores)
function thread_get_number()
{
	return 1;
}

/// CppSeparate IntType thread_get_id()
/// Returns the current thread
function thread_get_id()
{
	return 0;
}

/// CppSeparate void thread_task_begin()
/// Starts a multi-threaded task.
function thread_task_begin()
{
}

/// CppSeparate void thread_task_end()
/// Ends a multi-threaded task.
function thread_task_end()
{
}

/// CppSeparate IntType get_vertex_buffer_triangles()
function get_vertex_buffer_triangles()
{
	return -1;
}

/// CppSeparate IntType get_vertex_buffer_render_calls()
function get_vertex_buffer_render_calls()
{
	return -1;
}

/// CppSeparate IntType get_primitive_lines()
function get_primitive_lines()
{
	return -1;
}

/// CppSeparate IntType get_primitive_triangles()
function get_primitive_triangles()
{
	return -1;
}

/// CppSeparate IntType get_primitive_render_calls()
function get_primitive_render_calls()
{
	return -1;
}

/// CppSeparate IntType surface_create_ext2(IntType, IntType, BoolType, BoolType)
/// Creates a new surface with additional settings to toggle the depth buffer and HDR color modes (floating points).
function surface_create_ext2(width, height, depth = true, hdr = false)
{
	return surface_create(width, height)
}

/// CppSeparate void sprite_set_texture_page(IntType, BoolType)
/// Sets whether a specific sprite will use texture pages, default is enabled.
function sprite_set_texture_page(sprite, enabled)
{
}

/// CppSeparate void move_all_to_texture_page()
/// Move all newly loaded sprites to texture pages, when enabled.
function move_all_to_texture_page()
{
}

/// CppSeparate void submit_batch()
/// Submits the current batch of vertices for rendering and starts a new one.
function submit_batch()
{
}

/// CppSeparate void vertex_buffer_set_save_data(IntType, BoolType)
/// Sets whether the triangle data should be stored on the CPU for saving to cache.
function vertex_buffer_set_save_data(buffer, save)
{
}

/// CppSeparate void shader_submit_int(IntType, IntType)
function shader_submit_int(index, val)
{
	shader_set_uniform_i(index, val)
}

/// CppSeparate void shader_submit_float(IntType, RealType)
function shader_submit_float(index, val)
{
	shader_set_uniform_f(index, val)
}

/// CppSeparate void shader_submit_vec2(IntType, RealType, RealType)
function shader_submit_vec2(index, xx, yy)
{
	shader_set_uniform_f(index, xx, yy)
}

/// CppSeparate void shader_submit_vec3(IntType, RealType, RealType, RealType)
function shader_submit_vec3(index, xx, yy, zz)
{
	shader_set_uniform_f(index, xx, yy, zz)
}

/// CppSeparate void shader_submit_vec4(IntType, RealType, RealType, RealType, RealType)
function shader_submit_vec4(index, xx, yy, zz, ww)
{
	shader_set_uniform_f(index, xx, yy, zz, ww)
}

/// CppSeparate void shader_submit_float_array(IntType, VarType)
function shader_submit_float_array(index, arr)
{
	shader_set_uniform_f_array(index, arr)
}

/// CppSeparate void shader_submit_mat4_array(IntType, ArrType)
function shader_submit_mat4_array(index, arr)
{
	var floats = array(16 * array_length(arr));
	for (var m = 0; m < array_length(arr); m++)
		for (var i = 0; i < 16; i++)
			floats[m * 16 + i] = arr[@m][@i];
	
	shader_set_uniform_f_array(index, floats)
}

/// CppSeparate IntType show_message_ext(StringType, StringType, StringType, StringType, StringType)
/// Shows 3 buttons with custom text, returns the ID of the button pressed. Pressing X will act as button3.
function show_message_ext(title, text, button1, button2, button3)
{
	return question(text) ? 0 : 1;
}

/// CppSeparate IntType ds_int_map_create()
/// Create a fast hash-table map that will only take integers as keys.
/// This will automatically replace ds_map_create by CppGen if only integers are used as keys in the map.
function ds_int_map_create()
{
	return ds_map_create()
}

/// CppSeparate IntType ds_string_map_create()
/// Create a fast hash-table map that will only take strings as keys.
/// This will automatically replace ds_map_create by CppGen if only strings are used as keys in the map.
function ds_string_map_create()
{
	return ds_map_create()
}

/// CppSeparate void builder_add_face(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)
function builder_add_face()
{
	builder_add_triangle(
		argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], 
		argument[12], argument[13], argument[14], argument[15], argument[16], argument[17],
		argument[20]
	)
	builder_add_triangle(
		argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[0], argument[1], argument[2], 
		argument[16], argument[17], argument[18], argument[19], argument[12], argument[13],
		argument[20]
	)
}

/// CppSeparate void builder_add_triangle(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)
function builder_add_triangle()
{
	
	vbuffer_current = block_vbuffer_current
	vertex_wave = block_vertex_wave
	vertex_wave_zmin = block_vertex_wave_zmin
	vertex_wave_zmax = block_vertex_wave_zmax
	vertex_emissive = block_vertex_emissive
	vertex_subsurface = block_vertex_subsurface
	vertex_rgb = block_vertex_rgb
	
	vbuffer_add_triangle(
		argument[0], argument[1], argument[2],
		argument[3], argument[4], argument[5],
		argument[6], argument[7], argument[8],
		argument[9], argument[10],
		argument[11], argument[12],
		argument[13], argument[14],
		false, argument[15]
	)
}

/// CppSeparate BoolType clip_is_active()
function clip_is_active()
{
	return shader_clip_active
}

/// CppSeparate void update_frustum()
function update_frustum()
{
}