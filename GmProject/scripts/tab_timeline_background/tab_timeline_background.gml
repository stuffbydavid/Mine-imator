/// tab_timeline_background(tlx, tly, tlw, tlh, itemh, mouseinnames, mousetl)

function tab_timeline_background(tlx, tly, tlw, tlh, itemh, mouseinnames, mousetl)
{
	// Empty
	if (project_file != "" && !instance_exists(obj_timeline) && content_height > 100 && (ds_list_size(timeline_marker_list) = 0))
	{
		draw_set_font(font_body_big)
		
		var textwid = string_width(text_get("timelineempty"));
		if (tlw > (textwid + 32))
			draw_label(text_get("timelineempty"), floor(tlx + tlw/2 - textwid/2), floor(tly + tlh/2), fa_left, fa_middle, c_text_secondary, a_text_secondary)
	}
	
	// Keyframe backgrounds
	if (tlw <= 0 || tlh <= 0)
		return 0

	clip_begin(tlx, tly, tlw, tlh)
	
	dy = tly - (floor(timeline.ver_scroll.value) - timeline_list_first * itemh)
	for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
	{
		if (dy > tly + tlh)
			break
		
		dx = tlx
		
		var tl = tree_visible_list[|t];
		
		draw_divide(dx, dy + itemh, tlw)
		
		// Select highlight
		if (tl.selected || (mouseinnames && tl = mousetl))
			draw_box(dx, dy, tlw, itemh, false, c_accent_overlay, a_accent_overlay)
		
		// Hidden
		if (tl.hide)
			draw_box(dx, dy, tlw, itemh, false, c_level_bottom, .5)
		
		dy += itemh
	}
	
	clip_end()
}
