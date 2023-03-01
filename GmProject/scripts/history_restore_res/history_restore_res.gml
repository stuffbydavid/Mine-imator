/// history_restore_res(save)
/// @arg save

function history_restore_res(save)
{
	var res;
	res = new_obj(obj_resource)
	
	with (save)
		res_copy(res)
	
	save_folder = app.project_folder
	load_folder = app.project_folder
	
	with (res)
	{
		save_id = save.save_id
		
		res_load()
		
		// Restore template usage
		for (var s = 0; s < save.usage_model_amount; s++)
		{
			with (save_id_find(save.usage_model_save_id[s]))
			{
				if (model != null)
					model.count--
				model = res
			}
		}
		
		#region Model textures
		
		for (var s = 0; s < save.usage_model_tex_amount; s++)
		{
			with (save_id_find(save.usage_model_tex_save_id[s]))
			{
				model_tex.count--
				model_tex = res
			}
		}
		
		for (var s = 0; s < save.usage_model_tex_material_amount; s++)
		{
			with (save_id_find(save.usage_model_tex_material_save_id[s]))
			{
				model_tex_material.count--
				model_tex_material = res
			}
		}
		
		for (var s = 0; s < save.usage_model_tex_normal_amount; s++)
		{
			with (save_id_find(save.usage_model_tex_normal_save_id[s]))
			{
				model_tex_normal.count--
				model_tex_normal = res
			}
		}
		
		#endregion
		
		#region Item textures
		
		for (var s = 0; s < save.usage_item_tex_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_save_id[s]))
			{
				item_tex.count--
				item_tex = res
				render_generate_item()
			}
		}
		
		for (var s = 0; s < save.usage_item_tex_material_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_material_save_id[s]))
			{
				item_tex_material.count--
				item_tex_material = res
				render_generate_item()
			}
		}
		
		for (var s = 0; s < save.usage_item_tex_normal_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_normal_save_id[s]))
			{
				item_tex_normal.count--
				item_tex_normal = res
				render_generate_item()
			}
		}
		
		#endregion
		
		#region Block textures
		
		for (var s = 0; s < save.usage_block_tex_amount; s++)
		{
			with (save_id_find(save.usage_block_tex_save_id[s]))
			{
				block_tex.count--
				block_tex = res
			}
		}
		
		for (var s = 0; s < save.usage_block_tex_material_amount; s++)
		{
			with (save_id_find(save.usage_block_tex_material_save_id[s]))
			{
				block_tex_material.count--
				block_tex_material = res
			}
		}
		
		for (var s = 0; s < save.usage_block_tex_normal_amount; s++)
		{
			with (save_id_find(save.usage_block_tex_normal_save_id[s]))
			{
				block_tex_normal.count--
				block_tex_normal = res
			}
		}
		
		#endregion
		
		for (var s = 0; s < save.usage_scenery_amount; s++)
			with (save_id_find(save.usage_scenery_save_id[s]))
				scenery = res
		
		#region Shape textures
		
		for (var s = 0; s < save.usage_shape_tex_amount; s++)
			with (save_id_find(save.usage_shape_tex_save_id[s]))
				shape_tex = res
		
		for (var s = 0; s < save.usage_shape_tex_material_amount; s++)
			with (save_id_find(save.usage_shape_tex_material_save_id[s]))
				shape_tex_material = res
		
		for (var s = 0; s < save.usage_shape_tex_normal_amount; s++)
			with (save_id_find(save.usage_shape_tex_normal_save_id[s]))
				shape_tex_normal = res
		
		#endregion
		
		for (var s = 0; s < save.usage_text_font_amount; s++)
		{
			with (save_id_find(save.usage_text_font_save_id[s]))
			{
				text_font.count--
				text_font = res
			}
		}
		
		// Restore particle type usage
		for (var s = 0; s < save.usage_sprite_tex_amount; s++)
			with (save_id_find(save.usage_sprite_tex_save_id[s]))
				sprite_tex = res
		
		for (var s = 0; s < save.usage_sprite_template_tex_amount; s++)
			with (save_id_find(save.usage_sprite_template_tex_save_id[s]))
				sprite_template_tex = res
		
		// Restore keyframe usage
		for (var s = 0; s < save.usage_kf_texture_amount; s++)
			with (save_id_find(save.usage_kf_texture_tl_save_id[s]))
				keyframe_list[|save.usage_kf_texture_index[s]].value[e_value.TEXTURE_OBJ] = res
		
		for (var s = 0; s < save.usage_kf_sound_amount; s++)
			with (save_id_find(save.usage_kf_sound_tl_save_id[s]))
				keyframe_list[|save.usage_kf_sound_index[s]].value[e_value.SOUND_OBJ] = res
		
		for (var s = 0; s < save.usage_kf_text_font_amount; s++)
			with (save_id_find(save.usage_kf_text_font_tl_save_id[s]))
				keyframe_list[|save.usage_kf_text_font_index[s]].value[e_value.TEXT_FONT] = res
		
		// Restore timeline usage
		for (var s = 0; s < save.usage_tl_texture_amount; s++)
		{
			with (save_id_find(save.usage_tl_texture_save_id[s]))
			{
				value[e_value.TEXTURE_OBJ] = res
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_sound_amount; s++)
		{
			with (save_id_find(save.usage_tl_sound_save_id[s]))
			{
				value[e_value.SOUND_OBJ] = res
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_text_font_amount; s++)
		{
			with (save_id_find(save.usage_tl_text_font_save_id[s]))
			{
				value[e_value.TEXT_FONT] = res
				update_matrix = true
			}
		}
		
		// Restore background usage
		if (save.usage_background_image)
			app.background_image = res
		
		if (save.usage_background_sky_sun_tex)
		{
			app.background_sky_sun_tex.count--
			app.background_sky_sun_tex = res
		}
		
		if (save.usage_background_sky_moon_tex)
		{
			app.background_sky_moon_tex.count--
			app.background_sky_moon_tex = res
		}
		
		if (save.usage_background_sky_clouds_tex)
		{
			app.background_sky_clouds_tex.count--
			app.background_sky_clouds_tex = res
		}
		
		if (save.usage_background_ground_tex)
		{
			with (app)
			{
				background_ground_tex.count--
				background_ground_tex = res
				background_ground_update_texture()
			}
		}
		
		if (save.usage_background_ground_tex_material)
		{
			with (app)
			{
				background_ground_tex_material.count--
				background_ground_tex_material = res
				background_ground_update_texture_material()
			}
		}
		
		if (save.usage_background_ground_tex_normal)
		{
			with (app)
			{
				background_ground_tex_normal.count--
				background_ground_tex_normal = res
				background_ground_update_texture_normal()
			}
		}
		
		count += save.usage_model_amount
		count += save.usage_model_tex_amount
		count += save.usage_model_tex_material_amount
		count += save.usage_model_tex_normal_amount
		count += save.usage_item_tex_amount
		count += save.usage_block_tex_amount
		count += save.usage_block_tex_material_amount
		count += save.usage_block_tex_normal_amount
		count += save.usage_scenery_amount
		count += save.usage_shape_tex_amount
		count += save.usage_text_font_amount
		count += save.usage_sprite_tex_amount
		count += save.usage_sprite_template_tex_amount
		count += save.usage_kf_sound_amount
		count += save.usage_background_image
		count += save.usage_background_sky_sun_tex
		count += save.usage_background_sky_moon_tex
		count += save.usage_background_sky_clouds_tex
		count += save.usage_background_ground_tex
	}
	
	sortlist_add(app.res_list, res)
	
	return res
}
