/// @arg view

function view_navgizmo_draw(view)
{
	var dir, label, color, type, rad, tip, script, buttons;
	var center, viewdir, right, up, alpha, btnscript;
	dir = 0
	label = 1
	color = 2
	type = 3
	rad = 4
	script = view.camera != null ? null : camera_snap
	
	if (setting_z_is_up)
	{
		buttons = [
			[ [ vec3(1, 0, 0) ], "X", c_axisred, e_button.PRIMARY, 8 ],
			[ [ vec3(0, 1, 0) ], "Y", c_axisgreen, e_button.PRIMARY, 8 ],
			[ [ vec3(0, 0, 1) ], "Z", c_axisblue, e_button.PRIMARY, 8 ],
			[ [ vec3(-1, 0, 0) ], "-X", c_axisred, e_button.SECONDARY, 8 ],
			[ [ vec3(0, -1, 0) ], "-Y", c_axisgreen, e_button.SECONDARY, 8 ],
			[ [ vec3(0, 0, -1) ], "-Z", c_axisblue, e_button.SECONDARY, 8 ]
		]
	}
	else
	{
		buttons = [
			[ [ vec3(1, 0, 0) ], "X", c_axisred, e_button.PRIMARY, 8 ],
			[ [ vec3(0, 1, 0) ], "Z", c_axisblue, e_button.PRIMARY, 8 ],
			[ [ vec3(0, 0, 1) ], "Y", c_axisgreen, e_button.PRIMARY, 8 ],
			[ [ vec3(-1, 0, 0) ], "-X", c_axisred, e_button.SECONDARY, 8 ],
			[ [ vec3(0, -1, 0) ], "-Z", c_axisblue, e_button.SECONDARY, 8 ],
			[ [ vec3(0, 0, -1) ], "-Y", c_axisgreen, e_button.SECONDARY, 8 ]
		]
	}
	
	dx = content_x + content_width - (86 + 8)
	dy = content_y + 8
	dw = 86
	dh = 86
	center = [ dx + dw / 2, dy + dw / 2 ]

	view.navgizmo_mouseon = (!(view_second.show && view_second.mouseon) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon &&
		mouse_x >= dx && mouse_x < dx + dw && mouse_y >= dy && mouse_y < dy + dh)
	
	content_mouseon = (view.navgizmo_mouseon && app_mouse_box(dx, dy, dw, dh, "view/click"))
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
	
	draw_image(spr_circle_84, 0, dx+1, dy+1, 1, 1, c_toolbar, a_toolbar, 0)
	
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
		
		tip = ""
		if (script != null)
			tip = "tooltip/nav/snap_" + string_lower(string_replace(buttons[i][label], "-", ""))

		// If multiple buttons clicked, only run script for topmost one
		if (draw_button_circle(buttons[i][label], pos2d[X], pos2d[Y], buttons[i][rad], buttons[i][type], buttons[i][color], null, script, null, tip, false, true) && !view.navgizmo_dragged)
			btnscript = [ script, buttons[i][dir][0] ]
	}
	
	if (btnscript != null)
		script_execute(btnscript[0], btnscript[1])
	
	gpu_set_tex_filter(false)
	render_set_culling(true)
	draw_set_alpha(1)
}
