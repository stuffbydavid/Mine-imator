function tab_timeline_editor_path()
{
	tab_control_button_label()
	draw_button_label("timeline_editor/path/point_add", floor(dx + dw/2), dy, null, icons.PATH_POINT, e_button.PRIMARY, action_tl_path_point_add, fa_middle)
	tab_next()
	
	tab_control_switch()
	draw_switch("timeline_editor/path/closed", dx, dy, tl_edit.path_closed, action_tl_path_closed)
	tab_next()
	
	tab_control_switch()
	draw_switch("timeline_editor/path/smooth", dx, dy, tl_edit.path_smooth, action_tl_path_smooth)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("timeline_editor/path/detail", dx, dy, dragger_width, tl_edit.path_detail, 0.25, 1, no_limit, 6, 1, tab.path.tbx_detail, action_tl_path_detail, null, true, false, "timeline_editor/path/detail_tip")
	tab_next()
	
	tab_control_togglebutton()
	togglebutton_add("timeline_editor/path/shape/none", null, "none", tl_edit.path_shape = "none", action_tl_path_shape)
	togglebutton_add("timeline_editor/path/shape/flat", null, "flat", tl_edit.path_shape = "flat", action_tl_path_shape)
	togglebutton_add("timeline_editor/path/shape/tube", null, "tube", tl_edit.path_shape = "tube", action_tl_path_shape)
	draw_togglebutton("timeline_editor/path/shape", dx, dy)
	tab_next()
	
	if (tl_edit.path_shape != "none")
	{
		tab_collapse_start()
		
		tab_control_dragger()
		draw_dragger("timeline_editor/path/shape/radius", dx, dy, dragger_width, tl_edit.path_shape_radius, 0.1, 0.01, no_limit, 8, 0.01, tab.path.tbx_radius, action_tl_path_shape_radius)
		tab_next()
		
		tab_control_switch()
		draw_switch("timeline_editor/path/shape/invert", dx, dy, tl_edit.path_shape_invert, action_tl_path_shape_invert)
		tab_next()
		
		tab_control_switch()
		draw_switch("timeline_editor/path/shape/smooth_segments", dx, dy, tl_edit.path_shape_smooth_segments, action_tl_path_shape_smooth_segments, "timeline_editor/path/shape/smooth_segments_tip")
		tab_next()
		
		if (tl_edit.path_shape = "tube")
		{
			tab_control_switch()
			draw_switch("timeline_editor/path/shape/smooth_ring", dx, dy, tl_edit.path_shape_smooth_ring, action_tl_path_shape_smooth_ring, "timeline_editor/path/shape/smooth_ring_tip")
			tab_next()
			
			tab_control_dragger()
			draw_dragger("timeline_editor/path/shape/detail", dx, dy, dragger_width, tl_edit.path_shape_detail, 0.25, 3, no_limit, 6, 1, tab.path.tbx_shape_detail, action_tl_path_shape_detail)
			tab_next()
		}

		draw_divide(dx, dy, dw)
		dy += 12
		
		tab_control_switch()
		draw_switch("timeline_editor/path/shape/tex_mapped", dx, dy, tl_edit.path_shape_tex_mapped, action_tl_path_shape_tex_mapped, "timeline_editor/path/shape/tex_mapped_tip")
		tab_next()
		
		if (tl_edit.path_shape_tex_mapped)
		{
			// Export map (Identical to cylinder UV)
			tab_control_button_label()
		
			if (draw_button_label("timeline_editor/path/shape/save_map", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
			{
				var fn = file_dialog_save_image("path");
				if (fn != "")
					sprite_save_lib(spr_map_cylinder, 0, fn)
			}
		
			tab_next()
		}
		
		tab_control_dragger()
		draw_dragger("timeline_editor/path/shape/tex_length", dx, dy, dragger_width, tl_edit.path_shape_tex_length, 0.1, 0.01, no_limit, 16, 0.01, tab.path.tbx_tex_length, action_tl_path_shape_tex_length, null, true, false, "timeline_editor/path/shape/tex_length_tip")
		tab_next()
		
		tab_collapse_end()
	}
}
