/// res_event_destroy()
/// @desc Destroy event of a resource.

// Free model textures
if (model_texture_map)
{
	var key = ds_map_find_first(model_texture_map);
	while (!is_undefined(key))
	{
		texture_free(model_texture_map[? key])
		key = ds_map_find_next(model_texture_map, key)
	}
	ds_map_destroy(model_texture_map)
}

// Free skin
if (model_texture != null)
	texture_free(model_texture)
		
// Free blocks
if (block_sheet_texture != null)
	texture_free(block_sheet_texture)
	
if (block_sheet_ani_texture != null)
	for (var f = 0; f < block_sheet_ani_frames; f++)
		texture_free(block_sheet_ani_texture[f])
	
if (block_sheet_depth_list != null)
	ds_list_destroy(block_sheet_depth_list)
	
if (block_sheet_ani_depth_list != null)
	ds_list_destroy(block_sheet_ani_depth_list)
	
if (block_preview_texture != null)
	texture_free(block_preview_texture)

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

// Free sound
if (sound_index != null)
	audio_free_buffer_sound(sound_index)

if (sound_buffer != null)
	buffer_delete(sound_buffer)

// Clear references and update counters
with (obj_template)
{
	if (skin = other.id)
	{
		skin = res_def
		skin.count++
	}
	
	if (item_tex = other.id)
	{
		item_tex = res_def
		item_tex.count++
		temp_update_item()
	}
	
	if (block_tex = other.id)
	{
		block_tex = res_def
		block_tex.count++
	}
	
	if (scenery = other.id) 
		scenery = null
	
	if (shape_tex = other.id)
		shape_tex = null
	
	if (text_font = other.id)
	{
		text_font = res_def
		text_font.count++
	}
}

with (app.bench_settings)
{
	if (skin = other.id)
		skin = res_def
	
	if (item_tex = other.id)
	{
		item_tex = res_def
		temp_update_item()
	}
	
	if (block_tex = other.id)
		block_tex = res_def
	
	if (shape_tex = other.id)
		shape_tex = null
	
	if (text_font = other.id)
		text_font = res_def
	
	if (scenery = other.id)
		scenery = null
}

with (obj_particle_type)
{
	if (sprite_tex = other.id)
	{
		sprite_tex = res_def
		sprite_tex.count++
	}
}

with (obj_keyframe)
{
	if (value[e_value.TEXTURE_OBJ] = other.id)
		value[e_value.TEXTURE_OBJ] = null
	
	if (value[e_value.SOUND_OBJ] = other.id)
		value[e_value.SOUND_OBJ] = null
		
	if (value[e_value.TEXT_FONT] = other.id)
		value[e_value.TEXT_FONT] = null
}

with (obj_timeline)
{
	if (value[e_value.TEXTURE_OBJ] = other.id)
		value[e_value.TEXTURE_OBJ] = null
	
	if (value_inherit[e_value.TEXTURE_OBJ] = other.id)
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
		background_sky_sun_tex = res_def
		background_sky_sun_tex.count++
	}
	
	if (background_sky_moon_tex = other.id)
	{
		background_sky_moon_tex = res_def
		background_sky_moon_tex.count++
	}
	
	if (background_sky_clouds_tex = other.id)
	{
		background_sky_clouds_tex = res_def
		background_sky_clouds_tex.count++
	}
	
	if (background_ground_tex = other.id)
	{
		background_ground_tex = res_def
		background_ground_tex.count++
		background_ground_update_texture()
	}
}

res_edit = sortlist_remove(app.res_list, id)
