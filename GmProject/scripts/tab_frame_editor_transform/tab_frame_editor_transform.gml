function tab_frame_editor_transform()
{
	dy -= 8
	
	// Position
	var taby = dy;
	microani_set("tab/position", null, false, false, false)
	tab_frame_editor_position()
	microani_set("tab/position", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Rotation
	taby = dy
	microani_set("tab/rotation", null, false, false, false)
	tab_frame_editor_rotation()
	microani_set("tab/rotation", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Scale
	taby = dy
	microani_set("tab/scale", null, false, false, false)
	tab_frame_editor_scale()
	microani_set("tab/scale", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Bend
	taby = dy
	microani_set("tab/bend", null, false, false, false)
	tab_frame_editor_bend()
	microani_set("tab/bend", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Path point settings
	tab_frame_editor_path_point()
}
