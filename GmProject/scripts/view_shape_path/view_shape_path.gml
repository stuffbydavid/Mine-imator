/// view_shape_path(view, timeline)
/// @arg view
/// @arg timeline

function view_shape_path(view, tl)
{
	if (array_length(tl.path_table) < 2)
		return 0
	
	var showpoints = tl.selected;
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
	{
		var pointtl = tl.tree_list[|i];
		if (pointtl.selected && pointtl.type = e_tl_type.PATH_POINT)
		{
			showpoints = true
			continue
		}
	}
	
	var prevcoord, nextcoord, prevcoord2d, nextcoord2d, prevcoord2derror, nextcoord2derror, points;
	
	if (showpoints)
	{
		draw_set_color(c_controls)
		
		prevcoord = point3D_mul_matrix(tl.path_points_list[|0], tl.matrix)
		prevcoord2d = view_shape_project(prevcoord)
		prevcoord2derror = point3D_project_error
		points = ds_list_size(tl.path_points_list)
		
		if (!tl.path_closed)
			points--
		
		for (var i = 1; i <= points; i++)
		{
			nextcoord = point3D_mul_matrix(tl.path_points_list[|(i mod ds_list_size(tl.path_points_list))], tl.matrix)
			nextcoord2d = view_shape_project(nextcoord)
			nextcoord2derror = point3D_project_error
			
			if (!prevcoord2derror && !nextcoord2derror)
				view_shape_line_draw(prevcoord2d, nextcoord2d)
			
			prevcoord = nextcoord
			prevcoord2d = nextcoord2d
			prevcoord2derror = nextcoord2derror
		}
		
		draw_set_color(c_white)
	}
	
	prevcoord = tl.path_table_matrix[0]
	prevcoord2d = view_shape_project(prevcoord)
	prevcoord2derror = point3D_project_error
	
	if (showpoints || tl.path_shape = "none")
	{
		for (var i = 1; i < array_length(tl.path_table_matrix); i++)
		{
			nextcoord = tl.path_table_matrix[i]
			nextcoord2d = view_shape_project(nextcoord)
			nextcoord2derror = point3D_project_error
		
			if (!prevcoord2derror && !nextcoord2derror)
				view_shape_line_draw(prevcoord2d, nextcoord2d)
		
			prevcoord = nextcoord
			prevcoord2d = nextcoord2d
			prevcoord2derror = nextcoord2derror
		}
	}
	
	if (showpoints)
	{
		for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		{
			var pointtl = tl.tree_list[|i];
			
			if (pointtl.selected || pointtl.type != e_tl_type.PATH_POINT)
				continue
			
			nextcoord = point3D_mul_matrix(tl.path_points_list[|i], tl.matrix)
			nextcoord2d = view_shape_project(nextcoord)
			nextcoord2derror = point3D_project_error
			
			if (!nextcoord2derror)
			{
				draw_image(spr_circle_24, 0, nextcoord2d[X], nextcoord2d[Y], 1, 1, c_level_top, 1)
				draw_image(spr_icons, icons.PATH_POINT, nextcoord2d[X], nextcoord2d[Y], 1, 1, c_text_secondary, a_text_secondary)
				
				if (app_mouse_box(content_x + (nextcoord2d[X] - 13), content_y + (nextcoord2d[Y] - 13), 26, 26) && content_mouseon && view.control_mouseon_last = null)
				{
					mouse_cursor = cr_default
					
					if (mouse_left_pressed)
					{
						action_tl_select(pointtl)
						
						if (setting_timeline_select_jump)
							tl_jump(pointtl)
						
						window_busy = "viewpathpointclick"
					}
				}
			}
		}
	}
}
