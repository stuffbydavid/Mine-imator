/// @desc Renders a timeline object with minimal settings and materials, intended for selection, scene test and depth passes.

function render_world_tl_fast()
{
	if (!render_alpha_hash_force)
	{
		render_alpha_hash = render_alpha_hash_allowed && (alpha_mode = e_alpha_mode.DEFAULT ? app.project_render_alpha_mode : alpha_mode)
		render_set_uniform_int(e_uniform.ALPHA_HASH, render_alpha_hash)
	}

	if (wind != shader_uniform_wind)
	{
		shader_uniform_wind = wind
		render_set_uniform(e_uniform.WIND_ENABLE, shader_uniform_wind)
	}

	if (wind_terrain != shader_uniform_wind_terrain)
	{
		shader_uniform_wind_terrain = wind_terrain
		render_set_uniform(e_uniform.WIND_TERRAIN, shader_uniform_wind_terrain)
	}

	var windstrength = app.env_wind_strength * app.setting_wind_enable * value_inherit[e_value.WIND_INFLUENCE];
	if (windstrength != shader_uniform_wind_strength ||
		windstrength * app.env_wind_directional_strength != shader_uniform_wind_directional_strength)
	{
		shader_uniform_wind_strength = windstrength
		shader_uniform_wind_directional_strength = windstrength * app.env_wind_directional_strength
		render_set_uniform(e_uniform.WIND_STRENGTH, shader_uniform_wind_strength)
		render_set_uniform(e_uniform.WIND_DIRECTIONAL_STRENGTH, shader_uniform_wind_directional_strength)
	}

	if (type != e_tl_type.PARTICLE_SPAWNER)
	{
		var tex, res, outline, itemanimate;
		matrix_set(matrix_world, matrix_render)
		render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, 0, 0)

		switch (type)
		{
			case e_tl_type.MODEL_PART:
			{
				if (model_part != null && render_res_diffuse != null)
					render_world_model_part(model_part, render_res_diffuse, temp.model_texture_name_map, model_shape_vbuffer_map, temp.model_color_map, temp.model_shape_hide_list, temp.model_shape_texture_name_map, true)
				
				break
			}

			case e_tl_type.STRUCTURE:
			case e_tl_type.SCENERY:
			{
				render_world_scenery(null, render_res_diffuse, null, null)
				break
			}

			case e_tl_type.BLOCK:
			{
				render_world_block_meshes(temp, render_res_diffuse, null, null)
				break
			}

			case e_tl_type.ITEM:
			{
				itemanimate = (parent = null || parent = app || parent.object_index != obj_timeline || parent.type != e_tl_type.MODEL_PART)
				
				if (item_vbuffer = null)
					render_world_item_fast(temp.item_vbuffer, item_res, temp.item_sheet, temp.item_3d, temp.item_face_camera, temp.item_bounce && itemanimate, temp.item_spin && itemanimate)
				else
					render_world_item_fast(item_vbuffer, item_res, item_sheet, temp.item_3d, temp.item_face_camera, temp.item_bounce && itemanimate, temp.item_spin && itemanimate)
				
				break
			}

			case e_tl_type.TEXT:
			{
				outline = null
				if (has_temp && !value[e_value.TEXT_CUSTOM_OUTLINE])
				{
					if (temp.text_outline)
						outline = c_white
				}
				else if (value[e_value.TEXT_OUTLINE])
					outline = c_white
				
				render_world_text(text_vbuffer, text_texture, temp.text_face_camera, text_res, outline)
				
				break
			}

			case e_tl_type.MODEL:
			{
				if (temp.model != null)
				{
					res = res_eval(value_inherit[e_value.TEXTURE_OBJ])
					if (res = null)
						res = res_eval(temp.model_tex)
					
					if (res = null || res.block_sheet_texture[e_block_sheet.STATIC16] = null)
						res = mc_res
					
					render_world_block_meshes(temp.model, res, null, null)
					
					with (temp)
						res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
					
					if (render_world_blocks_transparent != true)
						render_world_block_map(temp.model.model_block_map, res)
				}
				
				break
			}

			case e_tl_type.PATH:
			{
				if (path_vbuffer != null)
				{
					tex = (value_inherit[e_value.TEXTURE_OBJ] = null) ? spr_shape : value_inherit[e_value.TEXTURE_OBJ].texture
					render_set_texture(value_inherit[e_value.TEXTURE_OBJ], tex)
					vbuffer_render(path_vbuffer)
				}
				else if (render_mode = e_render_mode.CLICK)
				{
					render_set_texture(null, spr_shape)
					vbuffer_render(path_select_vbuffer)
				}
				
				break
			}

			default:
			{
				with (temp)
					tex = temp_get_shape_tex(temp_get_shape_texobj(other.value_inherit[e_value.TEXTURE_OBJ]))
				
				render_world_shape(temp.type, temp.shape_vbuffer, temp.shape_face_camera, [ tex, null, null ])
				
				break
			}
		}
	}
	else if (render_particles)
	{
		for (var p = 0; p < ds_list_size(particle_list); p++)
			with (particle_list[|p])
				render_world_particle()
	}

	matrix_world_reset()
	
	shader_texture_surface = false
	
	return 0
}
