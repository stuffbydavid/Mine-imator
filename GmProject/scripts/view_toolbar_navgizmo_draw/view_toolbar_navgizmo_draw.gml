/// @arg view
/// @arg x
/// @arg y

function view_toolbar_navgizmo_draw(view, xx, yy)
{
	var dir, label, color, type, rad, tip, scr, buttons;
	var center, viewdir, right, up, alpha, btnscript;
	dir = 0
	label = 1
	color = 2
	type = 3
	rad = 4
	tip = 5
	scr = 6
	
	buttons = [
		[
			[ vec3(1, 0, 0) ], "X", c_axisred, e_button.PRIMARY, 8,
			view.camera != null ? "" : "tooltip/nav/snap_x", view.camera != null ? null : camera_snap
		],
		[
			[ vec3(0, 1, 0) ], setting_z_is_up ? "Y" : "Z", setting_z_is_up ? c_axisgreen : c_axisblue, e_button.PRIMARY, 8,
			view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_y" : "tooltip/nav/snap_z"), view.camera != null ? null : camera_snap
		],
		[
			[ vec3(0, 0, 1) ], setting_z_is_up ? "Z" : "Y", setting_z_is_up ? c_axisblue : c_axisgreen, e_button.PRIMARY, 8,
			view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_z" : "tooltip/nav/snap_y"), view.camera != null ? null : camera_snap
		],
		[
			[ vec3(-1, 0, 0) ], "-X", c_axisred, e_button.SECONDARY, 8,
			view.camera != null ? "" : "tooltip/nav/snap_x", view.camera != null ? null : camera_snap
		],
		[
			[ vec3(0, -1, 0) ], setting_z_is_up ? "-Y" : "-Z", setting_z_is_up ? c_axisgreen : c_axisblue, e_button.SECONDARY, 8,
			view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_y" : "tooltip/nav/snap_z"), view.camera != null ? null : camera_snap
		],
		[
			[ vec3(0, 0, -1) ], setting_z_is_up ? "-Z" : "-Y", setting_z_is_up ? c_axisblue : c_axisgreen, e_button.SECONDARY, 8,
			view.camera != null ? "" : (setting_z_is_up ? "tooltip/nav/snap_z" : "tooltip/nav/snap_y"), view.camera != null ? null : camera_snap
		]
	]
	
	dx = xx
	dy = yy
	dw = 86
	dh = 86
	center = [ dx + dw / 2, dy + dw / 2 ]
	
	content_mouseon = app_mouse_box(dx, dy, dw, dh, "view/click") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon)
	if (content_mouseon)
		mouse_cursor = cr_handpoint
	
	if (app_mouse_box(dx - 64, dy - 64, dw + 128, dh + 128) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		alpha = 1
	else
		alpha = .65
	
	if (window_busy = "view/rotate_camera" || window_busy = "view/move_camera")
		alpha = 1
	
	viewdir = vec3_direction(view.surface_cam_from, view.surface_cam_to)
	right = vec3_normalize(vec3_cross(viewdir, view.surface_cam_up))
	up = vec3_normalize(vec3_cross(right, viewdir))
	
	// Project axes onto the view
	for (var i = 0; i < array_length(buttons); i++)
	{
	    var vv, rx, ry, rz;
	    vv = buttons[i][dir][0]
		
	    rx = vec3_dot(vv, right)
	    ry = vec3_dot(vv, up)
	    rz = vec3_dot(vv, viewdir)
		
		buttons[i][dir][1] = vec3(rx, ry, rz)
	}
	
	// Sort buttons by Z depth
	for (var i = 0; i < array_length(buttons) - 1; i++)
	{
	    for (var j = 0; j < array_length(buttons) - 1 - i; j++)
	    {
	        if (buttons[j][dir][1][Z] < buttons[j + 1][dir][1][Z])
	        {
	            var temp = buttons[j];
	            buttons[j] = buttons[j + 1]
	            buttons[j + 1] = temp
	        }
	    }
	}
	
	draw_image(spr_circle_84, 0, dx+1, dy+1, 1, 1, merge_color(c_level_top, c_black, .5), .5, 0)
	
	draw_set_alpha(alpha)
	render_set_culling(false)
	gpu_set_tex_filter(true)
	
	btnscript = null
	for (var i = 0; i < array_length(buttons); i++)
	{
		var bdir, pos2d;
		bdir = buttons[i][dir][1]
	    pos2d = [ round(center[X] - ((dw / 2) - 8) * bdir[X]), round(center[Y] - ((dw / 2) - 8) * bdir[Y]) ]
		
		if (buttons[i][type] = e_button.PRIMARY)
		{
			draw_set_color(buttons[i][color])
			draw_line_width(center[X], center[Y], pos2d[X], pos2d[Y], 2)
			draw_set_color(c_white)
		}
		
		// If multiple buttons clicked, only run script for topmost one
		if (draw_button_circle(buttons[i][label], pos2d[X], pos2d[Y], buttons[i][rad], buttons[i][type], buttons[i][color], null, buttons[i][scr], null, buttons[i][tip], false, true) && !view.navgizmo_dragged)
			btnscript = [ buttons[i][scr], buttons[i][dir][0] ]
	}
	if (btnscript != null)
		script_execute(btnscript[0], btnscript[1])
	
	gpu_set_tex_filter(false)
	render_set_culling(true)
	draw_set_alpha(1)
}
