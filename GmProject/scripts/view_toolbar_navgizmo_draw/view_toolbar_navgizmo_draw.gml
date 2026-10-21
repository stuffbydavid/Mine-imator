/// @arg view
/// @arg x
/// @arg y
/// @arg buttonslist

function view_toolbar_navgizmo_draw(view, xx, yy, buttons = null)
{
	// Define buttons and their variables
	var dir, label, color, type, rad, tip, scr;
	dir = 0
	label = 1
	color = 2
	type = 3
	rad = 4
	tip = 5
	scr = 6
	
	if (buttons = null)
	{
		// this storage method is kinda stanky, oh well
		buttons = [
			[[vec3(1, 0, 0)], "X", c_axisred, e_button.PRIMARY, 8, view.camera != null ? "" : "tooltip/nav/snap_x", view.camera != null ? null : camera_snap],
			[[vec3(0, 1, 0)], setting_z_is_up ? "Y" : "Z", setting_z_is_up ? c_axisgreen : c_axisblue, e_button.PRIMARY, 8, view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_y" : "tooltip/nav/snap_z"), view.camera != null ? null : camera_snap],
			[[vec3(0, 0, 1)], setting_z_is_up ? "Z" : "Y", setting_z_is_up ? c_axisblue : c_axisgreen, e_button.PRIMARY, 8, view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_z" : "tooltip/nav/snap_y"), view.camera != null ? null : camera_snap],
			[[vec3(-1, 0, 0)], "-X", c_axisred, e_button.SECONDARY, 8, view.camera != null ? "" : "tooltip/nav/snap_x", view.camera != null ? null : camera_snap],
			[[vec3(0, -1, 0)], setting_z_is_up ? "-Y" : "-Z", setting_z_is_up ? c_axisgreen : c_axisblue, e_button.SECONDARY, 8, view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_y" : "tooltip/nav/snap_z"), view.camera != null ? null : camera_snap],
			[[vec3(0, 0, -1)], setting_z_is_up ? "-Z" : "-Y", setting_z_is_up ? c_axisblue : c_axisgreen, e_button.SECONDARY, 8, view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_z" : "tooltip/nav/snap_y"), view.camera != null ? null : camera_snap]
			//,[[vec3(sin(current_time / pi / 800) * 1.5, -cos(current_time / pi / 800) * 1.5, 0)], "?", c_text_main, e_button.PRIMARY, 12, "tooltip/tl/hide", null]
		]
	}
	
	dx = xx
	dy = yy
	dw = 86
	dh = 86
	var center = [dx + dw / 2, dy + dw / 2];
	
	content_mouseon = app_mouse_box(dx, dy, dw, dh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	if (app_mouse_box(dx - 64, dy - 64, dw + 128, dh + 128) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		view.navgizmo_alpha_goal = 1
	else
		view.navgizmo_alpha_goal = .65
	
	if (window_busy = "view/rotate_camera" || window_busy = "view/move_camera" || window_busy = "view/move_camera_toggle")
		view.navgizmo_alpha_goal = 1
	
	// Camera vectors
	var viewdir, right, up;
	viewdir = vec3_direction(view.surface_cam_from, view.surface_cam_to)
	right = vec3_normalize(vec3_cross(viewdir, view.surface_cam_up))
	up = vec3_normalize(vec3_cross(right, viewdir))
	
	//var str = "";
	// Get button positions and draw order
	for (var i = 0; i < array_length(buttons); i++)
	{
	    var vv, rx, ry, rz;
	    vv = buttons[i][dir][0]
		
	    rx = vec3_dot(vv, right)
	    ry = vec3_dot(vv, up)
	    rz = vec3_dot(vv, viewdir)
		
		buttons[i][dir][1] = vec3(rx, ry, rz)
		//str += (string(buttons[i][label]) + ": " + string(rx) + ", " + string(ry) + ", " + string(rz)) + "\n"
	}
	//draw_label(str, dx + dw, dy + 86, fa_right, fa_top, c_white, 1, font_label)
	
	// Sort buttons by Z depth
	for (var i = 0; i < array_length(buttons) - 1; i++)
	{
	    for (var j = 0; j < array_length(buttons) - 1 - i; j++)
	    {
	        if (buttons[j][dir][1][Z] < buttons[j + 1][dir][1][Z])
	        {
	            // Swap
	            var temp = buttons[j];
	            buttons[j] = buttons[j + 1]
	            buttons[j + 1] = temp
	        }
	    }
	}
	
	// Background
	//draw_box(dx, dy, dw, dh, false, c_yellow, 1)
	draw_image(spr_circle_84, 0, dx+1, dy+1, 1, 1, merge_color(c_level_top, c_black, .5), .5, 0)
	
	// Draw buttons
	draw_set_alpha(view.navgizmo_alpha_goal)
	render_set_culling(false)
	gpu_set_tex_filter(true)
	
	var tempz = 1;
	var btnscript = null;
	for (var i = 0; i < array_length(buttons); i++)
	{
		var bdir, pos2d;
		bdir = buttons[i][dir][1]
	    pos2d = [round(center[X] - ((dw / 2) - 8) * bdir[X]), round(center[Y] - ((dw / 2) - 8) * bdir[Y])]
		
		// Draw bottom buttons behind background
		//if (bdir[Z] <= 0 && tempz > 0)
		//	draw_image(spr_circle_84, 0, dx+1, dy+1, 1, 1, merge_color(c_level_top, c_black, .5), .5, 0)
		tempz = bdir[Z]
		
		if (buttons[i][type] = e_button.PRIMARY)
		{
			var offset = (is_cpp() ? 0.001 : -1);
			draw_set_color(buttons[i][color])
			draw_line_width(center[X]+offset, center[Y]+offset, pos2d[X]+offset, pos2d[Y]+offset, 2)
			draw_set_color(c_white)
		}
		
		// If multiple buttons clicked, only run script for topmost one
		if (draw_button_circle(buttons[i][label], pos2d[X], pos2d[Y], buttons[i][rad], buttons[i][type], buttons[i][color], null, buttons[i][scr], null, buttons[i][tip], false, true))
			btnscript = [buttons[i][scr], buttons[i][dir][0]]
	}
	if (btnscript != null)
		script_execute(btnscript[0], btnscript[1])
	
	gpu_set_tex_filter(false)
	render_set_culling(true)
	draw_set_alpha(1)
}