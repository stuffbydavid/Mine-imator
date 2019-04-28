/// history_save_res(resource)
/// @arg resource
/// @desc Saves a resource in memory.

var res, save;
res = argument0
save = new(obj_history_save)
save.hobj = id

with (res)
	res_copy(save)
	
with (save)
{
	save_id = res.save_id
	usage_model_amount = 0
	usage_model_tex_amount = 0
	usage_item_tex_amount = 0
	usage_block_tex_amount = 0
	usage_scenery_amount = 0
	usage_shape_tex_amount = 0
	usage_text_font_amount = 0
	usage_sprite_tex_amount = 0
	usage_sprite_template_tex_amount = 0
	usage_kf_texture_amount = 0
	usage_tl_texture_amount = 0
	usage_kf_sound_amount = 0
	usage_tl_sound_amount = 0
	usage_kf_text_font_amount = 0
	usage_tl_text_font_amount = 0
	usage_background_image = false
	usage_background_sky_sun_tex = false
	usage_background_sky_moon_tex = false
	usage_background_sky_clouds_tex = false
	usage_background_ground_tex = false
}

// Save references
with (obj_template)
{
	if (model = res)
	{
		save.usage_model_save_id[save.usage_model_amount] = save_id
		save.usage_model_amount++
	}
	
	if (model_tex = res)
	{
		save.usage_model_tex_save_id[save.usage_model_tex_amount] = save_id
		save.usage_model_tex_amount++
	}
	
	if (item_tex = res)
	{
		save.usage_item_tex_save_id[save.usage_item_tex_amount] = save_id
		save.usage_item_tex_amount++
	}
	
	if (block_tex = res)
	{
		save.usage_block_tex_save_id[save.usage_block_tex_amount] = save_id
		save.usage_block_tex_amount++
	}
	
	if (scenery = res)
	{
		save.usage_scenery_save_id[save.usage_scenery_amount] = save_id
		save.usage_scenery_amount++
	}
	
	if (shape_tex = res)
	{
		save.usage_shape_tex_save_id[save.usage_shape_tex_amount] = save_id
		save.usage_shape_tex_amount++
	}
	
	if (text_font = res)
	{
		save.usage_text_font_save_id[save.usage_text_font_amount] = save_id
		save.usage_text_font_amount++
	}
}

with (obj_particle_type)
{
	if (sprite_tex = res)
	{
		save.usage_sprite_tex_save_id[save.usage_sprite_tex_amount] = save_id
		save.usage_sprite_tex_amount++
	}
	
	if (sprite_template_tex = res)
	{
		save.usage_sprite_template_tex_save_id[save.usage_sprite_template_tex_amount] = save_id
		save.usage_sprite_template_tex_amount++
	}
}

with (obj_keyframe)
{
	if (value[e_value.TEXTURE_OBJ] = res)
	{
		save.usage_kf_texture_tl_save_id[save.usage_kf_texture_amount] = save_id_get(timeline)
		save.usage_kf_texture_index[save.usage_kf_texture_amount] = ds_list_find_index(timeline.keyframe_list, id)
		save.usage_kf_texture_amount++
	}
	
	if (value[e_value.SOUND_OBJ] = res)
	{
		save.usage_kf_sound_tl_save_id[save.usage_kf_sound_amount] = save_id_get(timeline)
		save.usage_kf_sound_index[save.usage_kf_sound_amount] = ds_list_find_index(timeline.keyframe_list, id)
		save.usage_kf_sound_amount++
	}
	
	if (value[e_value.TEXT_FONT] = res)
	{
		save.usage_kf_text_font_tl_save_id[save.usage_kf_text_font_amount] = save_id_get(timeline)
		save.usage_kf_text_font_index[save.usage_kf_text_font_amount] = ds_list_find_index(timeline.keyframe_list, id)
		save.usage_kf_text_font_amount++
	}
}

with (obj_timeline)
{
	if (value[e_value.TEXTURE_OBJ] = res)
	{
		save.usage_tl_texture_save_id[save.usage_tl_texture_amount] = save_id
		save.usage_tl_texture_amount++
	}
	
	if (value[e_value.SOUND_OBJ] = res)
	{
		save.usage_tl_sound_save_id[save.usage_tl_sound_amount] = save_id
		save.usage_tl_sound_amount++
	}
	
	if (value[e_value.TEXT_FONT] = res)
	{
		save.usage_tl_text_font_save_id[save.usage_tl_text_font_amount] = save_id
		save.usage_tl_text_font_amount++
	}
}

with (app)
{
	if (background_image = res)
		save.usage_background_image = true
		
	if (background_sky_sun_tex = res)
		save.usage_background_sky_sun_tex = true
		
	if (background_sky_moon_tex = res)
		save.usage_background_sky_moon_tex = true
		
	if (background_sky_clouds_tex = res)
		save.usage_background_sky_clouds_tex = true
		
	if (background_ground_tex = res)
		save.usage_background_ground_tex = true
}

return save
