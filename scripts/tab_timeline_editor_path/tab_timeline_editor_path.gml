/// tab_timeline_editor_path()

function tab_timeline_editor_path()
{
	tab_control_button_label()
	draw_button_label("timelineeditorpathpointadd", floor(dx + dw/2), dy, null, icons.PATH_POINT, e_button.PRIMARY, action_tl_path_point_add, fa_middle)
	tab_next()
	
	tab_control_switch()
	draw_switch("timelineeditorpathclosed", dx, dy, tl_edit.path_closed, action_tl_path_closed)
	tab_next()
	
	tab_control_switch()
	draw_switch("timelineeditorpathsmooth", dx, dy, tl_edit.path_smooth, action_tl_path_smooth)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("timelineeditorpathdetail", dx, dy, dragger_width, tl_edit.path_detail, 1 / 4, 1, no_limit, 6, 1, tab.path.tbx_detail, action_tl_path_detail, null, true, false, "timelineeditorpathdetailtip")
	tab_next()
	
	tab_control_switch()
	draw_button_collapse("path_shape", collapse_map[?"path_shape"], action_tl_path_shape_generate, tl_edit.path_shape_generate, "timelineeditorpathshape")
	tab_next()
	
	if (collapse_map[?"path_shape"] && tl_edit.path_shape_generate)
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("timelineeditorpathshaperadius", dx, dy, dragger_width, tl_edit.path_shape_radius, 0.1, 0.01, no_limit, 8, 0.01, tab.path.tbx_radius, action_tl_path_shape_radius)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("timelineeditorpathshapetexlength", dx, dy, dragger_width, tl_edit.path_shape_tex_length, 0.1, 0.01, no_limit, 16, 0.01, tab.path.tbx_tex_length, action_tl_path_shape_tex_length, null, true, false, "timelineeditorpathshapetexlengthtip")
		tab_next()
		
		tab_control_switch()
		draw_switch("timelineeditorpathshapeinvert", dx, dy, tl_edit.path_shape_invert, action_tl_path_shape_invert)
		tab_next()
		
		tab_control_switch()
		draw_switch("timelineeditorpathshapesmoothsegments", dx, dy, tl_edit.path_shape_smooth_segments, action_tl_path_shape_smooth_segments, "timelineeditorpathshapesmoothsegmentstip")
		tab_next()
		
		tab_control_switch()
		draw_button_collapse("path_shape_tube", collapse_map[?"path_shape_tube"], action_tl_path_shape_tube, tl_edit.path_shape_tube, "timelineeditorpathshapetube")
		tab_next()
		
		if (collapse_map[?"path_shape_tube"] && tl_edit.path_shape_tube)
		{
			tab_collapse_start()
			
			tab_control_dragger()
			draw_dragger("timelineeditorpathshapedetail", dx, dy, dragger_width, tl_edit.path_shape_detail, 1 / 4, 3, no_limit, 6, 1, tab.path.tbx_shape_detail, action_tl_path_shape_detail)
			tab_next()
			
			tab_control_switch()
			draw_switch("timelineeditorpathshapesmoothring", dx, dy, tl_edit.path_shape_smooth_ring, action_tl_path_shape_smooth_ring, "timelineeditorpathshapesmoothringtip")
			tab_next()
			
			tab_collapse_end()
		}
		
		tab_collapse_end()
	}
}
