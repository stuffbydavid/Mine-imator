/// res_load()
/// @desc Loads the file for the resource.

var fn = load_folder + "\\" + filename;

debug("Loading " + res_type_name_list[|type], fn)

if (load_folder != save_folder && type != e_res_type.LEGACY_BLOCK_SHEET)
	res_save()

// Load from file
switch (type)
{
	case e_res_type.PACK:
	case e_res_type.PACK_UNZIPPED:
	{
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 2)
			load_start(other.id, res_load_start)
		}
		
		break
	}
		
	case e_res_type.SKIN:
	case e_res_type.DOWNLOADED_SKIN:
	{
		if (model_texture)
			texture_free(model_texture)
		
		if (player_skin)
			model_texture = res_load_player_skin(fn)
		else
			model_texture = texture_create_square(fn)
			
		break
	}
		
	case e_res_type.ITEM_SHEET:
	{
		if (item_sheet_texture)
			texture_free(item_sheet_texture)
			
		item_sheet_texture = texture_create(fn)
		
		break
	}
	
	case e_res_type.LEGACY_BLOCK_SHEET:
	case e_res_type.BLOCK_SHEET:
	{
		if (block_sheet_texture != null)
			texture_free(block_sheet_texture)
			
		if (type = e_res_type.LEGACY_BLOCK_SHEET)
		{
			block_sheet_texture = res_load_legacy_block_sheet(fn, load_format)
			if (load_folder = save_folder)
				filename = filename_new_ext(filename_name(fn), "_converted" + filename_ext(fn))
			texture_export(block_sheet_texture, save_folder + "\\" + filename)
			type = e_res_type.BLOCK_SHEET
		}
		else
			block_sheet_texture = texture_create(fn)
		
		colormap_grass_texture = texture_duplicate(mc_res.colormap_grass_texture)
		colormap_foliage_texture = texture_duplicate(mc_res.colormap_foliage_texture)
			
		res_update_colors()
		res_update_block_preview()
		
		break
	}
		
	case e_res_type.SCHEMATIC:
	case e_res_type.FROM_WORLD:
	{
		ready = false
		
		with (app)
		{
			ds_priority_add(load_queue, other.id, 1)
			load_start(other.id, res_load_start)
		}
		
		break
	}
	
	case e_res_type.PARTICLE_SHEET:
	{
		if (particles_texture[0])
			texture_free(particles_texture[0])
			
		if (particles_texture[1])
			texture_free(particles_texture[1])
			
		particles_texture[0] = texture_create_square(fn)
		particles_texture[1] = particles_texture[0]
		
		break
	}
		
	case e_res_type.TEXTURE:
	{
		if (texture)
			texture_free(texture)
			
		texture = texture_create(fn)
		
		break
	}
		
	case e_res_type.FONT:
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
		
	case e_res_type.SOUND:
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
else if (type != e_res_type.PACK)
	display_name = filename_new_ext(filename, "")
else
	display_name = filename
	
if (type = e_res_type.DOWNLOADED_SKIN)
	display_name = text_get("downloadskinname", display_name)
