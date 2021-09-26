/// res_event_destroy()
/// @desc Called by the destroy event of a resource.

function res_event_destroy()
{
	// Free single model texture
	if (model_texture != null)
		texture_free(model_texture)
	
	// Free multiple model textures
	if (model_texture_map != null)
	{
		var key = ds_map_find_first(model_texture_map);
		while (!is_undefined(key))
		{
			texture_free(model_texture_map[?key])
			key = ds_map_find_next(model_texture_map, key)
		}
		ds_map_destroy(model_texture_map)
	}
	
	// Free shape vbuffers
	if (model_shape_vbuffer_map != null)
	{
		var key = ds_map_find_first(model_shape_vbuffer_map);
		while (!is_undefined(key))
		{
			if (instance_exists(key) && key.vbuffer_default != model_shape_vbuffer_map[?key]) // Don't clear default buffers
				vbuffer_destroy(model_shape_vbuffer_map[?key])
			key = ds_map_find_next(model_shape_vbuffer_map, key)
		}
		ds_map_destroy(model_shape_vbuffer_map)
	}
	
	if (model_shape_alpha_map != null)
		ds_map_destroy(model_shape_alpha_map)
	
	// Free block textures
	if (block_sheet_texture != null)
		texture_free(block_sheet_texture)
	
	if (block_sheet_material_texture != null)
		texture_free(block_sheet_material_texture)
	
	if (block_sheet_normal_texture != null)
		texture_free(block_sheet_normal_texture)
	
	if (block_sheet_ani_texture != null)
		for (var f = 0; f < block_sheet_ani_frames; f++)
			texture_free(block_sheet_ani_texture[f])
	
	if (block_sheet_ani_material_texture != null)
		for (var f = 0; f < block_sheet_ani_frames; f++)
			texture_free(block_sheet_ani_material_texture[f])
	
	if (block_sheet_ani_normal_texture != null)
		for (var f = 0; f < block_sheet_ani_frames; f++)
			texture_free(block_sheet_ani_normal_texture[f])
	
	if (block_sheet_depth_list != null)
		ds_list_destroy(block_sheet_depth_list)
	
	if (block_sheet_ani_depth_list != null)
		ds_list_destroy(block_sheet_ani_depth_list)
	
	if (block_preview_texture != null)
		texture_free(block_preview_texture)
	
	if (scenery_chunk_array != null)
		block_vbuffer_destroy()
	
	// Free items
	if (item_sheet_texture != null)
		texture_free(item_sheet_texture)
	
	// Free misc
	if (colormap_grass_texture != null)
		texture_free(colormap_grass_texture)
	
	if (colormap_foliage_texture != null)
		texture_free(colormap_foliage_texture)
	
	if (particles_texture[0] != null)
		texture_free(particles_texture[0])
	
	if (particles_texture[1] != null)
		texture_free(particles_texture[1])
	
	if (sun_texture != null)
		texture_free(sun_texture)
	
	if (moonphases_texture != null)
	{
		texture_free(moonphases_texture)
		for (var t = 0; t < 8; t++)
			texture_free(moon_texture[t])
	}
	
	if (clouds_texture != null)
		texture_free(clouds_texture)
	
	// Free texture
	if (texture != null)
		texture_free(texture)
	
	// Free font
	if (font_exists(font))
		font_delete(font)
	
	if (font_exists(font_preview))
		font_delete(font_preview)
	
	if (font_exists(font_no_aa))
		font_delete(font_no_aa)
	
	// Free sound
	if (sound_index != null)
		audio_free_buffer_sound(sound_index)
	
	if (sound_buffer != null)
		buffer_delete(sound_buffer)
	
	// Free blocks
	if (scenery_tl_list != null)
	{
		for (var i = 0; i < ds_list_size(scenery_tl_list); i++)
			with (scenery_tl_list[|i])
				instance_destroy()
		ds_list_destroy(scenery_tl_list)
	}
	
	if (model_block_map != null)
	{
		var key = ds_map_find_first(model_block_map);
		while (!is_undefined(key))
		{
			vbuffer_destroy(model_block_map[?key])
			key = ds_map_find_next(model_block_map, key)
		}
		ds_map_destroy(model_block_map)
	}
	
	// Clear references and update counters
	with (obj_template)
	{
		if (model = other.id)
			model = null
		
		if (model_tex = other.id)
		{
			model_tex = mc_res
			model_tex.count++
		}
		
		if (item_tex = other.id)
		{
			item_tex = mc_res
			item_tex.count++
			render_generate_item()
		}
		
		if (block_tex = other.id)
		{
			block_tex = mc_res
			block_tex.count++
		}
		
		if (block_material_tex = other.id)
		{
			block_material_tex = mc_res
			block_material_tex.count++
		}
		
		if (block_normal_tex = other.id)
		{
			block_normal_tex = mc_res
			block_normal_tex.count++
		}
		
		if (scenery = other.id) 
			scenery = null
		
		if (shape_tex = other.id)
			shape_tex = null
		
		if (text_font = other.id)
		{
			text_font = mc_res
			text_font.count++
		}
	}
	
	with (app.bench_settings)
	{
		if (model = other.id)
			model = null
		
		if (model_tex = other.id)
			model_tex = mc_res
		
		if (item_tex = other.id)
		{
			item_tex = mc_res
			render_generate_item()
		}
		
		if (block_tex = other.id)
			block_tex = mc_res
		
		if (block_material_tex = other.id)
			block_material_tex = mc_res
		
		if (block_normal_tex = other.id)
			block_normal_tex = mc_res
		
		if (shape_tex = other.id)
			shape_tex = null
		
		if (text_font = other.id)
			text_font = mc_res
		
		if (scenery = other.id)
			scenery = null
	}
	
	with (obj_particle_type)
	{
		if (sprite_tex = other.id)
		{
			sprite_tex = mc_res
			sprite_tex.count++
		}
		
		if (sprite_template_tex = other.id)
		{
			sprite_template_tex = mc_res
			sprite_template_tex.count++
		}	
	}
	
	with (obj_keyframe)
	{
		if (value[e_value.TEXTURE_OBJ] = other.id)
			value[e_value.TEXTURE_OBJ] = null
		
		if (value[e_value.TEXTURE_MATERIAL_OBJ] = other.id)
			value[e_value.TEXTURE_MATERIAL_OBJ] = null
		
		if (value[e_value.TEXTURE_NORMAL_OBJ] = other.id)
			value[e_value.TEXTURE_NORMAL_OBJ] = null
		
		if (value[e_value.SOUND_OBJ] = other.id)
			value[e_value.SOUND_OBJ] = null
		
		if (value[e_value.TEXT_FONT] = other.id)
			value[e_value.TEXT_FONT] = null
	}
	
	with (obj_timeline)
	{
		if (value[e_value.TEXTURE_OBJ] = other.id)
			value[e_value.TEXTURE_OBJ] = null
		
		if (value[e_value.TEXTURE_MATERIAL_OBJ] = other.id)
			value[e_value.TEXTURE_MATERIAL_OBJ] = null
		
		if (value[e_value.TEXTURE_NORMAL_OBJ] = other.id)
			value[e_value.TEXTURE_NORMAL_OBJ] = null
		
		if (value_inherit[e_value.TEXTURE_OBJ] = other.id)
			update_matrix = true
		
		if (value_inherit[e_value.TEXTURE_MATERIAL_OBJ] = other.id)
			update_matrix = true
		
		if (value_inherit[e_value.TEXTURE_NORMAL_OBJ] = other.id)
			update_matrix = true
		
		if (value[e_value.SOUND_OBJ] = other.id)
			value[e_value.SOUND_OBJ] = null
		
		if (value_inherit[e_value.SOUND_OBJ] = other.id)
			update_matrix = true
		
		if (value[e_value.TEXT_FONT] = other.id)
			value[e_value.TEXT_FONT] = null
		
		if (value_inherit[e_value.TEXT_FONT] = other.id)
			update_matrix = true
	}
	
	with (app)
	{
		if (background_image = other.id)
			background_image = null
		
		if (background_sky_sun_tex = other.id)
		{
			background_sky_sun_tex = mc_res
			background_sky_sun_tex.count++
		}
		
		if (background_sky_moon_tex = other.id)
		{
			background_sky_moon_tex = mc_res
			background_sky_moon_tex.count++
		}
		
		if (background_sky_clouds_tex = other.id)
		{
			background_sky_clouds_tex = mc_res
			background_sky_clouds_tex.count++
		}
		
		if (background_ground_tex = other.id)
		{
			background_ground_tex = mc_res
			background_ground_tex.count++
			background_ground_update_texture()
		}
		
		if (background_ground_material_tex = other.id)
		{
			background_ground_material_tex = mc_res
			background_ground_material_tex.count++
			background_ground_update_texture()
		}
		
		if (background_ground_normal_tex = other.id)
		{
			background_ground_normal_tex = mc_res
			background_ground_normal_tex.count++
			background_ground_update_normal_texture()
		}
	}
	
	// Remove from resource browser
	res_edit = sortlist_remove(app.res_list, id)
}
