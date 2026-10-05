/// @desc Transfers template data and runtime ownership between a timeline and template.
/// @arg source
/// @arg destination

function tl_copy_temp(src, dest)
{
	with (src)
	{
		dest.type = type
		dest.name = name
		
		if (type = e_tl_type.BLOCK)
		{
			dest.block_name = block_name
			dest.block_state = array_copy_1d(block_state)
			dest.block_tex = block_tex
			dest.block_tex_material = block_tex_material
			dest.block_tex_normal = block_tex_normal
			dest.block_repeat_enable = block_repeat_enable
			dest.block_repeat = array_copy_1d(block_repeat)
			dest.block_center_legacy = block_center_legacy
			dest.block_center = block_center
			dest.block_randomize = block_randomize
			dest.block_vbuffer = block_vbuffer
			dest.block_vbuffer_active = block_vbuffer_active
			dest.block_vbuffer_depth_active = block_vbuffer_depth_active
			block_vbuffer = null
		}
		else if (type = e_tl_type.TEXT)
		{
			dest.text_font = text_font
			dest.text_3d = text_3d
			dest.text_face_camera = text_face_camera
			dest.text_aa = text_aa
			if (object_index = obj_timeline)
			{
				dest.text_outline = value[e_value.TEXT_OUTLINE]
				dest.text_outline_color = value[e_value.TEXT_OUTLINE_COLOR]
				dest.text_outline_size = value[e_value.TEXT_OUTLINE_SIZE]
				dest.text_halign = value[e_value.TEXT_HALIGN]
				dest.text_valign = value[e_value.TEXT_VALIGN]
			}
		}
		else
		{
			dest.model_name = model_name
			dest.model_state = array_copy_1d(model_state)
			dest.model_tex = model_tex
			dest.model_tex_material = model_tex_material
			dest.model_tex_normal = model_tex_normal
			dest.model_use_blend_color = model_use_blend_color
			dest.model_blend_color = model_blend_color
			dest.model_blend_color_default = model_blend_color_default
			dest.pattern_type = pattern_type
			dest.pattern_base_color = pattern_base_color
			dest.pattern_pattern_list = array_copy_1d(pattern_pattern_list)
			dest.pattern_color_list = array_copy_1d(pattern_color_list)
			
			if (type = e_tl_type.SPECIAL_BLOCK)
			{
				dest.model_file = model_file
				dest.model_texture_name_map = model_texture_name_map
				dest.model_texture_material_name_map = model_texture_material_name_map
				dest.model_texture_normal_name_map = model_texture_normal_name_map
				dest.model_shape_texture_name_map = model_shape_texture_name_map
				dest.model_shape_texture_material_name_map = model_shape_texture_material_name_map
				dest.model_shape_texture_normal_name_map = model_shape_texture_normal_name_map
				dest.model_hide_list = model_hide_list
				dest.model_shape_hide_list = model_shape_hide_list
				dest.model_color_name_map = model_color_name_map
				dest.model_color_map = model_color_map
				dest.model_shape_vbuffer_map = model_shape_vbuffer_map
				dest.model_shape_alpha_map = model_shape_alpha_map
				dest.pattern_skin = pattern_skin
				
				model_file = null
				model_texture_name_map = null
				model_texture_material_name_map = null
				model_texture_normal_name_map = null
				model_shape_texture_name_map = null
				model_shape_texture_material_name_map = null
				model_shape_texture_normal_name_map = null
				model_hide_list = null
				model_shape_hide_list = null
				model_color_name_map = null
				model_color_map = null
				model_shape_vbuffer_map = null
				model_shape_alpha_map = null
				pattern_skin = null
			}
		}
		
		if (is_array(pattern_update))
		{
			for (var i = 0; i < array_length(pattern_update); i++)
				if (pattern_update[i] = id)
					pattern_update[i] = dest
		}
		else if (pattern_update = id)
			pattern_update = dest
	}
	
	// Link the timeline hierarchy
	with (obj_timeline)
	{
		if (temp != src)
			continue
		
		self.temp = dest
		has_temp = (dest.object_index = obj_template)
	}
}
