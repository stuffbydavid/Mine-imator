/// tab_frame_editor_transform()

function tab_frame_editor_transform()
{
	dy -= 8
	
	var taby;
	
	// Position
	taby = dy
	microani_set("tabposition", null, false, false, false)
	tab_frame_editor_position()
	microani_set("tabposition", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Rotation
	taby = dy
	microani_set("tabrotation", null, false, false, false)
	tab_frame_editor_rotation()
	microani_set("tabrotation", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Scale
	taby = dy
	microani_set("tabscale", null, false, false, false)
	tab_frame_editor_scale()
	microani_set("tabscale", null, false, false, false)
	microani_update(app_mouse_box(dx, taby, dw, dy - taby) && content_mouseon, false, false)
	
	// Bend
	tab_frame_editor_bend()
	
	// Path point settings
	tab_frame_editor_path_point()
}
