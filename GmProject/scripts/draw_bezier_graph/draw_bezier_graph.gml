/// draw_bezier_graph(x, y, width, height, points, sync)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg points
/// @arg sync

function draw_bezier_graph(xx, yy, wid, hei, points, sync)
{
	var vertical, boxx, boxy, boxw, boxh, update;
	vertical = (hei > wid)
	boxx = xx
	boxy = yy + hei / 6
	boxw = wid
	boxh = hei / 1.5
	update = false
	
	draw_box(xx, yy, wid, hei, false, c_level_bottom, 1)
	draw_box(boxx, boxy, boxw, boxh, false, c_level_top, 1)
	draw_outline(xx, yy, wid, hei, 1, c_border, a_border, true)
	
	var easeinxpos, easeinypos, easeoutxpos, easeoutypos, colorin, colorout;
	easeinxpos = boxx + boxw * points[0]
	easeinypos = (boxy + boxh) - boxh * points[1]
	easeoutxpos = boxx + boxw * points[2]
	easeoutypos = (boxy + boxh) - boxh * points[3]
	
	gpu_set_cullmode(false)
	
	clip_begin(xx, yy, wid, hei)
	gpu_set_tex_filter(true)
	
	// Draw curve
	draw_bezier_curve([boxx, boxy + boxh], [easeinxpos, easeinypos], [easeoutxpos, easeoutypos], [boxx + boxw, boxy], 2, c_text_secondary, a_text_secondary)
	
	// Preview progress
	if (tl_edit != null)
		draw_box(xx + wid * tl_edit.keyframe_progress, yy, 2, hei, false, c_red, .30)
	
	// Draw handles
	draw_image(spr_handle, 0, boxx, boxy + boxh, .75, point_distance(boxx, boxy + boxh, easeinxpos, easeinypos), c_accent, 1, point_direction(boxx, boxy + boxh, easeinxpos, easeinypos) - 90)
	draw_image(spr_handle, 0, boxx + boxw, boxy, .75, point_distance(boxx + boxw, boxy, easeoutxpos, easeoutypos), c_accent, 1, point_direction(boxx + boxw, boxy, easeoutxpos, easeoutypos) - 90)
	
	gpu_set_tex_filter(false)
	clip_end()
	
	colorin = (easeinypos < yy || easeinypos > yy + hei ? c_error : c_accent)
	easeinxpos = clamp(easeinxpos, boxx, boxx + boxw)
	easeinypos = clamp(easeinypos, yy, yy + hei)
	
	colorout = (easeoutypos < yy || easeoutypos > yy + hei ? c_error : c_accent)
	easeoutxpos = clamp(easeoutxpos, boxx, boxx + boxw)
	easeoutypos = clamp(easeoutypos, yy, yy + hei)
	
	draw_box(easeinxpos - 6, easeinypos - 6, 12, 12, false, colorin, 1)
	draw_box(easeinxpos - 3, easeinypos - 3, 6, 6, false, c_level_top, 1)
	
	draw_box(easeoutxpos - 6, easeoutypos - 6, 12, 12, false, colorout, 1)
	draw_box(easeoutxpos - 3, easeoutypos - 3, 6, 6, false, c_level_top, 1)
	
	// Ease-in handle
	if (app_mouse_box(easeinxpos - 5, easeinypos - 5, 10, 10))
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left)
		{
			window_busy = "beziereasein"
			handle_drag_offset_x = mouse_x - easeinxpos
			handle_drag_offset_y = mouse_y - easeinypos
		}
	}
	
	// Ease-out handle
	if (app_mouse_box(easeoutxpos - 5, easeoutypos - 5, 10, 10))
	{
		mouse_cursor = cr_handpoint
		handle_drag_offset_x = mouse_x - easeoutxpos
		handle_drag_offset_y = mouse_y - easeoutypos
		
		if (mouse_left)
		{
			window_busy = "beziereaseout"
			handle_drag_offset_x = mouse_x - easeoutxpos
			handle_drag_offset_y = mouse_y - easeoutypos
		}
	}
	
	points[0] *= 100
	points[1] *= 100
	points[2] *= 100
	points[3] *= 100
	
	// You know what to do
	if (window_busy = "beziereasein")
	{
		mouse_cursor = cr_handpoint
		
		if (!mouse_still)
		{
			points[0] = floor(percent(mouse_x - handle_drag_offset_x, boxx, boxx + boxw) * 100)
			points[1] = floor(percent(mouse_y - handle_drag_offset_y, boxy + boxh, boxy, false) * 100)
			
			if (sync)
			{
				points[2] = 100 - points[0]
				points[3] = 100 - points[1]
			}
			
			update = true
		}
		
		if (!mouse_left)
			window_busy = ""
	}
	
	if (window_busy = "beziereaseout")
	{
		mouse_cursor = cr_handpoint
		
		if (!mouse_still)
		{
			points[2] = floor(percent(mouse_x - handle_drag_offset_x, boxx, boxx + boxw) * 100)
			points[3] = floor(percent(mouse_y - handle_drag_offset_y, boxy + boxh, boxy, false) * 100)
			
			if (sync)
			{
				points[0] = 100 - points[2]
				points[1] = 100 - points[3]
			}
			
			update = true
		}
		
		if (!mouse_left)
			window_busy = ""
	}
	
	if (update)
	{
		points[0] /= 100
		points[1] /= 100
		points[2] /= 100
		points[3] /= 100
		
		if (sync)
			action_tl_frame_ease_all(points, false)
		else if (window_busy = "beziereasein")
			action_tl_frame_ease_in(points, false)
		else
			action_tl_frame_ease_out([points[2], points[3]], false)
	}
}