/// res_load_scenery()
/// @desc Creates vertex buffers from a schematic or blocks file.
///		  The process is split into three steps for opening, reading and generating.

var fname, openerr, rootmap;
fname = load_folder + "\\" + filename
openerr = false
rootmap = null

switch (load_stage)
{
	// Open file
	case "open":
	{
		if (!file_exists_lib(fname))
		{
			with (app)
				load_next()
			return 0
		}
		
		// .blocks file (legacy)
		if (filename_ext(fname) = ".blocks")
		{
			log("Loading .blocks", fname)
			
			buffer_current = buffer_load_lib(fname)
			with (mc_builder)
			{
				file_map = buffer_read_string_short_be()
				build_size[Y] = buffer_read_short_be() // Derp
				build_size[X] = buffer_read_short_be()
				build_size[Z] = buffer_read_short_be()
				log("Size", mc_builder.build_size)
			
				for (build_pos[Z] = 0; build_pos[Z] < build_size[Z]; build_pos[Z]++)
				{
					for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
					{
						for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
						{
							var bid, bdata, block;
							bid = buffer_read_byte()
							bdata = buffer_read_byte()
							block = mc_assets.block_legacy_id_map[?bid]
							array3D_set(block_obj, build_pos, block)
							if (is_undefined(block))
								array3D_set(block_state, build_pos, "")
							else
								array3D_set(block_state, build_pos, block.legacy_data_state[bdata])
						}
					}
				}
			}
		}
		
		// Schematic file
		else
		{
			log("Loading .schematic", fname)
		
			// Unzip
			file_delete_lib(temp_file)
			gzunzip(fname, temp_file)
			buffer_current = buffer_load(temp_file)
			openerr = true
		
			// Read NBT structure
			rootmap = nbt_read_tag_compound();
			if (rootmap = null)
				break
			
			if (dev_mode_debug_schematics)
				nbt_debug_tag_compound("root", rootmap)
			
			// Get Schematic tag
			var schematicmap = rootmap[?"Schematic"];
			if (is_undefined(schematicmap))
			{
				log("Schematic error", "Not a schematic file")
				break
			}
			
			// Get size
			mc_builder.build_size[X] = schematicmap[?"Width"]
			mc_builder.build_size[Y] = schematicmap[?"Length"]
			mc_builder.build_size[Z] = schematicmap[?"Height"]
			if (is_undefined(mc_builder.build_size[X]) || 
				is_undefined(mc_builder.build_size[Y]) || 
				is_undefined(mc_builder.build_size[Z]))
			{
				log("Schematic error", "Size not fully defined")
				break
			}
			log("Size", mc_builder.build_size)
			
			if (mc_builder.build_size[X] = 0 || 
				mc_builder.build_size[Y] = 0 || 
				mc_builder.build_size[Z] = 0)
			{
				log("Schematic error", "Size cannot be 0")
				break
			}
			
			// Get block/data array
			var blocksarray = schematicmap[?"Blocks"];
			if (is_undefined(blocksarray))
			{
				log("Schematic error", "Blocks array not found")
				break
			}
			var dataarray = schematicmap[?"Data"];
			if (is_undefined(dataarray))
			{
				log("Schematic error", "Data array not found")
				break
			}
			
			// Get map
			mc_builder.file_map = schematicmap[?"FromMap"]
			if (is_undefined(mc_builder.file_map))
				mc_builder.file_map = ""
				
			// Parse blocks
			with (mc_builder)
			{
				// ID
				buffer_seek(buffer_current, buffer_seek_start, blocksarray)
				for (build_pos[Z] = 0; build_pos[Z] < build_size[Z]; build_pos[Z]++)
					for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
						for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
							array3D_set(block_obj, build_pos, mc_assets.block_legacy_id_map[?buffer_read_byte()])
					
				// Data
				buffer_seek(buffer_current, buffer_seek_start, dataarray)
				for (build_pos[Z] = 0; build_pos[Z] < build_size[Z]; build_pos[Z]++)
				{
					for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
					{
						for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
						{
							var block, bdata = buffer_read_byte();
							block = array3D_get(block_obj, build_pos)
							if (is_undefined(block))
								array3D_set(block_state, build_pos, "")
							else
								array3D_set(block_state, build_pos, block.legacy_data_state[bdata])
						}
					}
				}
			}
		}
		
		openerr = false
		
		// Free file buffer
		buffer_delete(buffer_current)
			
		load_stage = "blocks"
		mc_builder.build_pos = point3D(0, 0, 0)
		with (app)
		{
			popup_loading.text = text_get("loadsceneryblocks")
			if (mc_builder.file_map != "")
				popup_loading.caption = text_get("loadscenerycaptionpieceof", mc_builder.file_map)
			else
				popup_loading.caption = text_get("loadscenerycaption", other.filename)
			popup_loading.progress = 2 / 10
		}
		break
	}
		
	// Read blocks
	case "blocks":
	{
		// Set models
		with (mc_builder)
		{
			for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
				for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
					builder_set_models()
			
			build_pos[Z]++
		}
		
		if (mc_builder.build_pos[Z] = mc_builder.build_size[Z])
		{
			// Prepare vbuffers
			block_vbuffer_start()
		
			load_stage = "model"
			mc_builder.build_pos[Z] = 0
			
			with (app)
				popup_loading.text = text_get("loadscenerymodel")
		}
		else
			with (app)
				popup_loading.progress = 2 / 10 + (2 / 10) * (mc_builder.build_pos[Z] / mc_builder.build_size[Z])
		
		break
	}
		
	// Generate model
	case "model":
	{
		with (mc_builder)
		{
			for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
				for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
					builder_generate()
					
			build_pos[Z]++
		}
		
		// All done
		if (mc_builder.build_pos[Z] = mc_builder.build_size[Z])
		{
			block_vbuffer_done()
			scenery_size = vec3(mc_builder.build_size[Y], mc_builder.build_size[X], mc_builder.build_size[Z]) // Rotate 90 degrees
			ready = true

			// Put map name in resource name
			if (mc_builder.file_map != "")
			{
				display_name = text_get("loadscenerypieceof", mc_builder.file_map)
				if (type = "fromworld") // Rename world import file
				{
					type = "schematic"
					var newname = filename_get_unique(app.project_folder + "\\" + display_name + ".schematic");
					filename = filename_name(newname)
					display_name = filename_new_ext(filename, "")
					file_rename_lib(app.project_folder + "\\export.schematic", newname)
				}
			}
				
			// Update rotation points
			with (obj_template)
				if (scenery = other.id)
					temp_update_rot_point()
			
			// Next
			with (app)
				load_next()
		}
		else
			with (app)
				popup_loading.progress = 4 / 10 + (6 / 10) * (mc_builder.build_pos[Z] / mc_builder.build_size[Z])
		
		break
	}
}

if (rootmap != null)
	ds_map_destroy(rootmap)

// Schematic error
if (openerr)
{
	error("errorloadschematic")
	buffer_delete(buffer_current)
	with (app)
		load_next()
}