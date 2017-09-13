/// res_load()
/// @desc Loads the file for the resource.

var fn = load_folder + "\\" + filename;

debug("Loading " + type, fn)

if (load_folder != save_folder && type != "legacyblocksheet")
	res_save()

// Load from file
switch (type)
{
	case "pack":
	case "packunzipped":
	{
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 2)
			load_start(other.id, res_load_start)
		}
		
		break
	}
		
	case "skin":
	case "downloadskin":
	{
		if (model_texture)
			texture_free(model_texture)
		
		if (player_skin)
			model_texture = res_load_player_skin(fn)
		else
			model_texture = texture_create_square(fn)
			
		break
	}
		
	case "itemsheet":
	{
		if (item_sheet_texture)
			texture_free(item_sheet_texture)
			
		item_sheet_texture = texture_create(fn)
		
		break
	}
	
	case "legacyblocksheet":
	case "blocksheet":
	{
		if (block_sheet_texture != null)
			texture_free(block_sheet_texture)
			
		if (type = "legacyblocksheet")
		{
			block_sheet_texture = res_load_legacy_block_sheet(fn, load_format)
			if (load_folder = save_folder)
				filename = filename_new_ext(filename_name(fn), "_converted" + filename_ext(fn))
			texture_export(block_sheet_texture, save_folder + "\\" + filename)
			type = "blocksheet"
		}
		else
			block_sheet_texture = texture_create(fn)
		
		colormap_grass_texture = texture_duplicate(res_def.colormap_grass_texture)
		colormap_foliage_texture = texture_duplicate(res_def.colormap_foliage_texture)
			
		res_update_colors()
		res_update_block_preview()
		
		break
	}
		
	case "schematic":
	case "fromworld":
	{
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 1)
			load_start(other.id, res_load_start)
		}
		
		break
	}
	
	case "particlesheet":
	{
		if (particles_texture[0])
			texture_free(particles_texture[0])
			
		if (particles_texture[1])
			texture_free(particles_texture[1])
			
		particles_texture[0] = texture_create_square(fn)
		particles_texture[1] = particles_texture[0]
		
		break
	}
		
	case "texture":
	{
		if (texture)
			texture_free(texture)
			
		texture = texture_create(fn)
		
		break
	}
		
	case "font":
	{
		if (font_exists(font))
			font_delete(font)
			
		if (font_exists(font_preview))
			font_delete(font_preview)
			
		font = font_add_lib(fn, 48, false, false)
		font_preview = font_add_lib(fn, 12, false, false)
		
		if (!font)
		{
			font = new_minecraft_font()
			font_preview = new_minecraft_font()
			font_minecraft = true
		}
		
		break
	}
		
	case "sound":
	{
		audio_stop_all()
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 0)
			load_start(other.id, res_load_start)
		}
		
		break
	}
}

// Set display name
if (filename_ext(fn) = ".zip")
	display_name = string_replace(filename, ".zip", "")
else if (type != "pack")
	display_name = filename_new_ext(filename, "")
else
	display_name = filename
	
if (type = "downloadskin")
	display_name = text_get("downloadskinname", display_name)
