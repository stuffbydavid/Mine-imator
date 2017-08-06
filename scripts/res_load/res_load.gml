/// res_load()
/// @desc Loads the file for the resource.

var fn = load_folder + "\\" + filename;

debug("Loading " + type, fn)

// Load from file
switch (type)
{
	case "pack":
	case "packunzipped":
	{
		if (type = "packunzipped") // Pre-unzipped pack (when loading assets)
		{
			pack_zip = ""
			type = "pack"
		}
		else
			pack_zip = fn
			
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 0)
			load_start(other.id, res_load_start)
		}
		
		break
	}
		
	case "skin":
	case "downloadskin":
	{
		if (model_texture)
			texture_free(model_texture)
		
		if (is_skin)
			model_texture = res_load_skin(fn)
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
	
	case "blocksheet":
	{
		if (block_sheet_texture != null)
			texture_free(block_sheet_texture)
			
		block_sheet_texture = texture_create(fn)
		
		colormap_grass_texture = texture_duplicate(res_def.colormap_grass_texture)
		colormap_foliage_texture = texture_duplicate(res_def.colormap_foliage_texture)
			
		res_update_colors()
		res_update_block_preview()
		
		break
	}
		
	case "schematic":
	{
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 2)
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
			font_exists(font)
			
		if (font_exists(font_preview))
			font_exists(font_preview)
			
		font = font_import(fn, 48, false, false)
		font_preview = font_import(fn, 12, false, false)
		
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
