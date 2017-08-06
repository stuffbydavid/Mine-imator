/// history_save_res(resource)
/// @arg resource

var res, save;
res = argument0
save = new(obj_history_save)
save.hobj = id

with (res)
	res_copy(save)
	
with (save)
{
	usage_char_skin_amount = 0
	usage_item_tex_amount = 0
	usage_block_tex_amount = 0
	usage_scenery_amount = 0
	usage_shape_tex_amount = 0
	usage_text_font_amount = 0
	usage_sprite_tex_amount = 0
	usage_kf_texture_amount = 0
	usage_tl_texture_amount = 0
	usage_kf_sound_amount = 0
	usage_tl_sound_amount = 0
	usage_background_image = false
	usage_background_sky_sun_tex = false
	usage_background_sky_moon_tex = false
	usage_background_sky_clouds_tex = false
	usage_background_ground = false
}

// Save references
with (obj_template)
{
	if (char_skin = res)
	{
		save.usage_char_skin[save.usage_char_skin_amount] = iid
		save.usage_char_skin_amount++
	}
	
	if (item_tex = res)
	{
		save.usage_item_tex[save.usage_item_tex_amount] = iid
		save.usage_item_tex_amount++
	}
	
	if (block_tex = res)
	{
		save.usage_block_tex[save.usage_block_tex_amount] = iid
		save.usage_block_tex_amount++
	}
	
	if (scenery = res)
	{
		save.usage_scenery[save.usage_scenery_amount] = iid
		save.usage_scenery_amount++
	}
	
	if (shape_tex = res)
	{
		save.usage_shape_tex[save.usage_shape_tex_amount] = iid
		save.usage_shape_tex_amount++
	}
	
	if (text_font = res)
	{
		save.usage_text_font[save.usage_text_font_amount] = iid
		save.usage_text_font_amount++
	}
}

with (obj_particle_type)
{
	if (sprite_tex = res)
	{
		save.usage_sprite_tex[save.usage_sprite_tex_amount] = iid
		save.usage_sprite_tex_amount++
	}
}

with (obj_keyframe)
{
	if (value[TEXTUREOBJ] = res)
	{
		save.usage_kf_texture_tl[save.usage_kf_texture_amount] = iid_get(tl)
		save.usage_kf_texture_index[save.usage_kf_texture_amount] = index
		save.usage_kf_texture_amount++
	}
	
	if (value[SOUNDOBJ] = res)
	{
		save.usage_kf_sound_tl[save.usage_kf_sound_amount] = iid_get(tl)
		save.usage_kf_sound_index[save.usage_kf_sound_amount] = index
		save.usage_kf_sound_amount++
	}
}

with (obj_timeline)
{
	if (value[TEXTUREOBJ] = res)
	{
		save.usage_tl_texture[save.usage_tl_texture_amount] = iid
		save.usage_tl_texture_amount++
	}
	
	if (value[SOUNDOBJ] = res)
	{
		save.usage_tl_sound[save.usage_tl_sound_amount] = iid
		save.usage_tl_sound_amount++
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
