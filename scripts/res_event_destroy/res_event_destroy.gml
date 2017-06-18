/// res_event_destroy()
/// @desc Destroy event of a resource.

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

if (model_texture)
	texture_free(model_texture)
        
for (var b = 0; b < block_frames; b++)
    if (block_texture[b])
        texture_free(block_texture[b])
	
if (block_preview_texture)
    texture_free(block_preview_texture)

if (colormap_grass_texture)
    texture_free(colormap_grass_texture)

if (colormap_foliage_texture)
    texture_free(colormap_foliage_texture)

if (item_texture)
    texture_free(item_texture)

if (particles_texture[0])
    texture_free(particles_texture[0])

if (particles_texture[1])
    texture_free(particles_texture[1])

if (texture)
    texture_free(texture)

if (sun_texture)
    texture_free(sun_texture)

if (moonphases_texture)
    texture_free(moonphases_texture)

if (moon_texture[0])
    for (var t = 0; t < 8; t++)
        texture_free(moon_texture[t])

if (clouds_texture)
    texture_free(clouds_texture)

if (font_exists(font))
    font_delete(font)

if (font_exists(font_preview))
    font_delete(font_preview)

if (sound_index)
    audio_free_buffer_sound(sound_index)

if (sound_buffer)
    buffer_delete(sound_buffer)

block_vbuffer_destroy()

// Clear references
with (obj_template)
{
    if (char_skin = other.id)
	{
        char_skin = res_def
        char_skin.count++
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
        scenery = 0
	
    if (shape_tex = other.id)
        shape_tex = 0
	
    if (text_font = other.id)
	{
        text_font = res_def
        text_font.count++
    }
}

with (app.bench_settings)
{
    if (char_skin = other.id)
        char_skin = res_def
	
    if (item_tex = other.id)
	{
        item_tex = res_def
        temp_update_item()
    }
	
    if (block_tex = other.id)
        block_tex = res_def
	
    if (shape_tex = other.id)
        shape_tex = 0
	
    if (text_font = other.id)
        text_font = res_def
	
    if (scenery = other.id)
        scenery = 0
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
    if (value[TEXTUREOBJ] = other.id)
        value[TEXTUREOBJ] = null
	
    if (value[SOUNDOBJ] = other.id)
        value[SOUNDOBJ] = null
}

with (obj_timeline)
{
    if (value[TEXTUREOBJ] = other.id)
        value[TEXTUREOBJ] = null
	
    if (value_inherit[TEXTUREOBJ] = other.id)
        update_matrix = true
	
    if (value[SOUNDOBJ] = other.id)
        value[SOUNDOBJ] = null
	
    if (value_inherit[SOUNDOBJ] = other.id)
        update_matrix = true
}

with (app)
{
    if (background_image = other.id)
        background_image = 0
	
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
	
    if (background_ground = other.id)
	{
        background_ground = res_def
        background_ground.count++
        background_ground_update_texture()
    }
}

res_edit = sortlist_remove(app.res_list, id)
