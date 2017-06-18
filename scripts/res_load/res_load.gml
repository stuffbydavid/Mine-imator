/// res_load()
/// @desc Loads the file for the resource.

var fn = load_folder + "\\" + filename;

debug("Loading " + type, fn)

switch (type)
{
	case "packunzipped":
		pack_zip = ""
		pack_export = true
		type = "pack"
		ready = false
		//ds_queue_enqueue(pack_load_queue, id)
		//with (app)
		//	res_pack_load_start()
		break
	
	case "pack":
		if (filename_ext(fn) = ".zip")
		{
			pack_zip = fn
			pack_export = (load_folder != save_folder)
			ready = false
			//ds_queue_enqueue(pack_load_queue, id)
			//with (app)
			//	res_pack_load_start()
		}
		else
		{
			//res_pack_load_folder(fn)
			res_update_colors()
		}
		break
		
	case "skin":
	case "downloadskin":
		if (model_texture)
			texture_free(model_texture)
		
		if (is_skin)
			model_texture = res_load_skin(fn)
		else
			model_texture = texture_create_square(fn)
		break
		
	case "itemsheet":
		if (item_texture)
			texture_free(item_texture)
		item_texture = texture_create_square(fn)
		break
		
	case "blocksheet":
		/*block_ani[32 * 16] = false
		
		for (var b = 0; b < block_frames; b++)
			if (block_texture[b])
				texture_free(block_texture[b])
			
		block_frames = 1
		block_texture[0] = texture_create(fn)
		
		if (block_format)
		{
			//block_texture[0] = res_load_blocks_convert(block_texture[0], block_format)
			block_format = null
		}
		
		colormap_grass_texture = texture_duplicate(res_def.colormap_grass_texture)
		colormap_foliage_texture = texture_duplicate(res_def.colormap_foliage_texture)
		
		res_update_colors()
		res_update_block_preview()*/
		
		break
		
	case "schematic":
		ready = false
		with (app)
		{
			ds_priority_add(load_queue, other.id, 2)
			load_start(other.id, res_load_start)
		}
		break
	
	case "particlesheet":
		if (particles_texture[0])
			texture_free(particles_texture[0])
		if (particles_texture[1])
			texture_free(particles_texture[1])
			
		particles_texture[0] = texture_create_square(fn)
		particles_texture[1] = particles_texture[0]
		
		break
		
	case "texture":
		if (texture)
			texture_free(texture)
		texture = texture_create(fn)
		break
		
	case "font":
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
		
	case "sound":
		audio_stop_all()
		ready = false
		
		ds_priority_add(res_load_queue, id, 0)
		with (app)
		{
			ds_priority_add(load_queue, other.id, 0)
			load_start(other.id, res_load_start)
		}
		break
}

if (load_folder != save_folder)
	res_export()
	
filename = filename_out
if (filename_ext(fn) = ".zip")
	display_name = string_replace(filename, ".zip", "")
else if (type != "pack")
	display_name = filename_new_ext(filename, "")
else
	display_name = filename
	
if (type = "downloadskin")
	display_name = text_get("downloadskinname", display_name)
else if (type = "pack")
	filename = display_name
