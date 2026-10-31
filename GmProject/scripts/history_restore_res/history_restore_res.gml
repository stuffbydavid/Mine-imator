function history_restore_res(save)
{
	var res = new_obj(obj_resource);
	
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
			with (save_id_find(save.usage_model_save_id[s]))
				model = res
		
		// Restore model textures
		for (var s = 0; s < save.usage_model_tex_amount; s++)
			with (save_id_find(save.usage_model_tex_save_id[s]))
				model_tex = res
		
		for (var s = 0; s < save.usage_model_tex_material_amount; s++)
			with (save_id_find(save.usage_model_tex_material_save_id[s]))
				model_tex_material = res
		
		for (var s = 0; s < save.usage_model_tex_normal_amount; s++)
			with (save_id_find(save.usage_model_tex_normal_save_id[s]))
				model_tex_normal = res
		
		// Restore item textures
		for (var s = 0; s < save.usage_item_tex_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_save_id[s]))
			{
				item_tex = res
				render_generate_item()
			}
		}
		
		for (var s = 0; s < save.usage_item_tex_material_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_material_save_id[s]))
			{
				item_tex_material = res
				render_generate_item()
			}
		}
		
		for (var s = 0; s < save.usage_item_tex_normal_amount; s++)
		{
			with (save_id_find(save.usage_item_tex_normal_save_id[s]))
			{
				item_tex_normal = res
				render_generate_item()
			}
		}
		
		// Restore block textures
		for (var s = 0; s < save.usage_block_tex_amount; s++)
			with (save_id_find(save.usage_block_tex_save_id[s]))
				block_tex = res
		
		for (var s = 0; s < save.usage_block_tex_material_amount; s++)
			with (save_id_find(save.usage_block_tex_material_save_id[s]))
				block_tex_material = res
		
		for (var s = 0; s < save.usage_block_tex_normal_amount; s++)
			with (save_id_find(save.usage_block_tex_normal_save_id[s]))
				block_tex_normal = res
		
		// Restore scenery
		for (var s = 0; s < save.usage_scenery_amount; s++)
			with (save_id_find(save.usage_scenery_save_id[s]))
				scenery = res
		
		// Restore shape textures
		for (var s = 0; s < save.usage_shape_tex_amount; s++)
			with (save_id_find(save.usage_shape_tex_save_id[s]))
				shape_tex = res
		
		for (var s = 0; s < save.usage_shape_tex_material_amount; s++)
			with (save_id_find(save.usage_shape_tex_material_save_id[s]))
				shape_tex_material = res
		
		for (var s = 0; s < save.usage_shape_tex_normal_amount; s++)
			with (save_id_find(save.usage_shape_tex_normal_save_id[s]))
				shape_tex_normal = res
		
		// Restore font
		for (var s = 0; s < save.usage_text_font_amount; s++)
			with (save_id_find(save.usage_text_font_save_id[s]))
				text_font = res
		
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

		for (var s = 0; s < save.usage_tl_default_text_font_amount; s++)
			with (save_id_find(save.usage_tl_default_text_font_save_id[s]))
				text_font = res
		
		for (var s = 0; s < save.usage_tl_glint_tex_amount; s++)
			with (save_id_find(save.usage_tl_glint_tex_save_id[s]))
				glint_tex = res

		for (var s = 0; s < save.usage_tl_block_tex_amount; s++)
			with (save_id_find(save.usage_tl_block_tex_save_id[s]))
				block_tex = res

		for (var s = 0; s < save.usage_tl_block_tex_material_amount; s++)
			with (save_id_find(save.usage_tl_block_tex_material_save_id[s]))
				block_tex_material = res

		for (var s = 0; s < save.usage_tl_block_tex_normal_amount; s++)
			with (save_id_find(save.usage_tl_block_tex_normal_save_id[s]))
				block_tex_normal = res

		// Restore background usage
		if (save.usage_env_background_image)
			app.env_background_image = res
		
		if (save.usage_env_sky_sun_tex)
			app.env_sky_sun_tex = res
		
		if (save.usage_env_sky_moon_tex)
			app.env_sky_moon_tex = res
		
		if (save.usage_env_sky_clouds_tex)
			app.env_sky_clouds_tex = res
		
		if (save.usage_env_ground_tex)
		{
			with (app)
			{
				env_ground_tex = res
				env_ground_update_texture()
			}
		}
		
		if (save.usage_env_ground_tex_material)
		{
			with (app)
			{
				env_ground_tex_material = res
				env_ground_update_texture_material()
			}
		}
		
		if (save.usage_env_ground_tex_normal)
		{
			with (app)
			{
				env_ground_tex_normal = res
				env_ground_update_texture_normal()
			}
		}
		
	}
	
	with (res)
		res_add_lists()
	
	return res
}
