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
	draw_dragger("timelineeditorpathdetail", dx, dy, dragger_width, tl_edit.path_detail, 0.25, 1, no_limit, 6, 1, tab.path.tbx_detail, action_tl_path_detail, null, true, false, "timelineeditorpathdetailtip")
	tab_next()
	
	tab_control_togglebutton()
	togglebutton_add("timelineeditorpathshapenone", null, "none", tl_edit.path_shape = "none", action_tl_path_shape)
	togglebutton_add("timelineeditorpathshapeflat", null, "flat", tl_edit.path_shape = "flat", action_tl_path_shape)
	togglebutton_add("timelineeditorpathshapetube", null, "tube", tl_edit.path_shape = "tube", action_tl_path_shape)
	draw_togglebutton("timelineeditorpathshape", dx, dy)
	tab_next()
	
	if (tl_edit.path_shape != "none")
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("timelineeditorpathshaperadius", dx, dy, dragger_width, tl_edit.path_shape_radius, 0.1, 0.01, no_limit, 8, 0.01, tab.path.tbx_radius, action_tl_path_shape_radius)
		tab_next()
		
		tab_control_switch()
		draw_switch("timelineeditorpathshapeinvert", dx, dy, tl_edit.path_shape_invert, action_tl_path_shape_invert)
		tab_next()
		
		tab_control_switch()
		draw_switch("timelineeditorpathshapesmoothsegments", dx, dy, tl_edit.path_shape_smooth_segments, action_tl_path_shape_smooth_segments, "timelineeditorpathshapesmoothsegmentstip")
		tab_next()
		
		if (tl_edit.path_shape = "tube")
		{
			tab_control_switch()
			draw_switch("timelineeditorpathshapesmoothring", dx, dy, tl_edit.path_shape_smooth_ring, action_tl_path_shape_smooth_ring, "timelineeditorpathshapesmoothringtip")
			tab_next()
			
			tab_control_dragger()
			draw_dragger("timelineeditorpathshapedetail", dx, dy, dragger_width, tl_edit.path_shape_detail, 0.25, 3, no_limit, 6, 1, tab.path.tbx_shape_detail, action_tl_path_shape_detail)
			tab_next()
		}

		draw_divide(dx, dy, dw)
		dy += 12
		
		tab_control_switch()
		draw_switch("timelineeditorpathshapetexmapped", dx, dy, tl_edit.path_shape_tex_mapped, action_tl_path_shape_tex_mapped, "timelineeditorpathshapetexmappedtip")
		tab_next()
		
		if (tl_edit.path_shape_tex_mapped)
		{
			// Export map (Identical to cylinder UV)
			tab_control_button_label()
		
			if (draw_button_label("timelineeditorpathshapesavemap", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
			{
				var fn = file_dialog_save_image("path");
				if (fn != "")
					sprite_save_lib(spr_map_cylinder, 0, fn)
			}
		
			tab_next()
		}
		
		tab_control_dragger()
		draw_dragger("timelineeditorpathshapetexlength", dx, dy, dragger_width, tl_edit.path_shape_tex_length, 0.1, 0.01, no_limit, 16, 0.01, tab.path.tbx_tex_length, action_tl_path_shape_tex_length, null, true, false, "timelineeditorpathshapetexlengthtip")
		tab_next()
		
		tab_collapse_end()
	}
}
