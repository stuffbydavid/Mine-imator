/// res_load([reload])
/// @desc Loads the file for the resource.

function res_load(reload = false)
{
	var fn = load_folder + "/" + filename;
	
	debug("Loading " + res_type_name_list[|type], fn)
	
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
				texture_export(block_sheet_texture, save_folder + "/" + filename)
				type = e_res_type.BLOCK_SHEET
			}
			else
				block_sheet_texture = texture_create(fn)
			
			block_sheet_texture_material = texture_duplicate(block_sheet_texture)
			block_sheet_tex_normal = texture_duplicate(block_sheet_texture)
			
			colormap_grass_texture = texture_duplicate(mc_res.colormap_grass_texture)
			colormap_foliage_texture = texture_duplicate(mc_res.colormap_foliage_texture)
			colormap_dry_foliage_texture = texture_duplicate(mc_res.colormap_dry_foliage_texture)
			
			res_update_colors()
			res_update_block_preview()
			
			break
		}
		
		case e_res_type.SCENERY:
		case e_res_type.FROM_WORLD:
		{
			// Load from cached mesh
			var cachefn = fn + ".meshcache";
			if (!reload && file_exists_lib(cachefn) && res_load_block_cache(cachefn))
				break
				
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
			
			texture = null
			
			if (filename_ext(fn) = ".dat")
			{
				var map = new_minecraft_map(fn);
				
				if (!map)
				{
					error("errorloadmap")
					break
				}
				else
					texture = new_minecraft_map(fn)
			}
			else
				texture = texture_create(fn)
			
			break
		}
		
		case e_res_type.FONT:
		{
			if (font_exists(font))
				font_delete(font)
			
			if (font_exists(font_preview))
				font_delete(font_preview)
			
			if (font_exists(font_no_aa))
				font_delete(font_no_aa)
			
			font = font_add_lib(fn, 48, false, false)
			font_no_aa = font_add_lib(fn, 48, false, false, false)
			font_preview = font_add_lib(fn, 12, false, false)
			
			if (!font)
			{
				font = new_minecraft_font()
				font_preview = new_minecraft_font()
				font_no_aa = new_minecraft_font()
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
		
		case e_res_type.MODEL:
		{
			instance_activate_object(model_file)
			with (model_file)
				instance_destroy()
			
			// Clear old block model map
			if (model_block_map != null)
			{
				var key = ds_map_find_first(model_block_map);
				while (!is_undefined(key))
				{
					vbuffer_destroy(model_block_map[?key])
					key = ds_map_find_next(model_block_map, key)
				}
				ds_map_destroy(model_block_map)
				model_block_map = null
			}
			
			// Create texture map (file.png/jpg->texture)
			if (model_texture_map != null)
			{
				var key = ds_map_find_first(model_texture_map);
				while (!is_undefined(key))
				{
					texture_free(model_texture_map[?key])
					key = ds_map_find_next(model_texture_map, key)
				}
				ds_map_destroy(model_texture_map)
				model_texture_map = null
			}
			
			if (model_texture_material_map != null)
			{
				var key = ds_map_find_first(model_texture_material_map);
				while (!is_undefined(key))
				{
					texture_free(model_texture_material_map[?key])
					key = ds_map_find_next(model_texture_material_map, key)
				}
				ds_map_destroy(model_texture_material_map)
				model_texture_material_map = null
			}
			
			if (model_tex_normal_map != null)
			{
				var key = ds_map_find_first(model_tex_normal_map);
				while (!is_undefined(key))
				{
					texture_free(model_tex_normal_map[?key])
					key = ds_map_find_next(model_tex_normal_map, key)
				}
				ds_map_destroy(model_tex_normal_map)
				model_tex_normal_map = null
			}
			
			// Load model from .mimodel or block .json
			if (filename_ext(fn) = ".mimodel")
			{
				model_format = e_model_format.MIMODEL
				model_file = model_file_load(fn, id) // model_file will be null if unsuccessful
				
				if (model_file = null)
					error("errorloadmodel")
				
				// Create texture name maps
				if (model_texture_name_map != null)
					ds_map_clear(model_texture_name_map)
				else
					model_texture_name_map = ds_map_create()
				
				if (model_file != null)
					model_texture_name_map[?""] = model_file.texture_name
				
				if (model_texture_material_name_map != null)
					ds_map_clear(model_texture_material_name_map)
				else
					model_texture_material_name_map = ds_map_create()
				
				if (model_file != null)
					model_texture_material_name_map[?""] = model_file.texture_material_name
				
				if (model_tex_normal_name_map != null)
					ds_map_clear(model_tex_normal_name_map)
				else
					model_tex_normal_name_map = ds_map_create()
				
				if (model_file != null)
					model_tex_normal_name_map[?""] = model_file.texture_normal_name
				
				// Create color name map
				if (model_color_name_map != null)
					ds_map_clear(model_color_name_map)
				else
					model_color_name_map = ds_map_create()
				
				res_update_model_shape()
				model_shape_update_color()
			}
			else
			{
				model_format = e_model_format.BLOCK
				model_file = null
				block_vbuffer = null
				
				// Load model file
				var blockmodel = block_load_model_file(fn, id);
				if (blockmodel = null)
				{
					error("errorloadmodel")
					break
				}
				
				model_block_map = ds_map_create()
				
				// Create render model
				var rendermodel = block_load_render_model(blockmodel, vec3(0), false, false, 0, id);
				
				// Generate triangles from render model
				block_vbuffer_start()
				with (mc_builder)
				{
					build_size_x = 1
					build_size_y = 1
					build_size_z = 1
					build_randomize = other.scenery_randomize
					
					builder_start()
					builder_spawn_threads(1)
					with (thread_list[|0])
					{
						builder_thread_set_pos(0)
						block_render_model_generate(rendermodel)
					}
					builder_combine_threads()
					builder_done()
					
					build_randomize = false
				}
				block_vbuffer_done()
				
				// Freeze block vbuffer map
				var key = ds_map_find_first(model_block_map);
				while (!is_undefined(key))
				{
					vertex_end(model_block_map[?key])
					model_block_map[?key] = vbuffer_generate_tangents(model_block_map[?key])
					vertex_freeze(model_block_map[?key])
					key = ds_map_find_next(model_block_map, key)
				}
				
				with (blockmodel)
					instance_destroy()
			}
			break
		}
	}
	
	if (load_folder != save_folder && type != e_res_type.LEGACY_BLOCK_SHEET)
		res_save()
	
	res_update_display_name()
}
