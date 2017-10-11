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
			debug_timer_start()
			
			buffer_current = buffer_load_lib(fname)
			with (mc_builder)
			{
				file_map = buffer_read_string_short_be()
				build_size[Y] = buffer_read_short_be() // Derp
				build_size[X] = buffer_read_short_be()
				build_size[Z] = buffer_read_short_be()
				
				builder_set_size()
				log("Size", build_size)
			
				for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
				{
					for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
					{
						for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
						{
							var bid, bdata, block;
							bid = buffer_read_byte()
							bdata = buffer_read_byte()
							block = mc_assets.block_legacy_id_map[?bid]
							if (!is_undefined(block))
							{
								array3D_set(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z, block)
								array3D_set(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z, block.legacy_data_state_id[bdata])
							}
						}
					}
				}
			}
			debug_timer_stop("res_load_scenery: Loaded .blocks")
		}
		
		// Schematic file
		else
		{
			log("Loading .schematic", fname)
			debug_timer_start()
		
			// Unzip
			file_delete_lib(temp_file)
			gzunzip(fname, temp_file)
			buffer_current = buffer_load(temp_file)
			openerr = true
		
			// Read NBT structure
			rootmap = nbt_read_tag_compound();
			if (rootmap = null)
				break
				
			debug_timer_stop("res_load_scenery, Parse NBT")
			
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
			log("Size", mc_builder.build_size)
				
			if (is_undefined(mc_builder.build_size[X]) || 
				is_undefined(mc_builder.build_size[Y]) || 
				is_undefined(mc_builder.build_size[Z]))
			{
				log("Schematic error", "Size not fully defined")
				break
			}
			
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
				debug_timer_start()
				
				builder_set_size()
					
				// Block
				buffer_seek(buffer_current, buffer_seek_start, blocksarray)
				for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
				{
					for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
					{
						for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
						{
							var block = mc_assets.block_legacy_id_map[?buffer_read_byte()];
							if (!is_undefined(block))
								array3D_set(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z, block)
						}
					}
				}
					
				// State
				buffer_seek(buffer_current, buffer_seek_start, dataarray)
				for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
				{
					for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
					{
						for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
						{
							var block, bdata;
							block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z, build_pos)
							bdata = buffer_read_byte()
							if (block != null)
								array3D_set(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z, block.legacy_data_state_id[bdata])
						}
					}
				}
				
				debug_timer_stop("res_load_scenery, Parse blocks")
				
				// Tile entities
				var tileentitylist = schematicmap[?"TileEntities"];
				if (ds_list_valid(tileentitylist))
				{
					debug_timer_start()
					for (var i = 0; i < ds_list_size(tileentitylist); i++)
					{
						var entity, eid, ex, ey, ez;
						entity = tileentitylist[|i]
						eid = entity[?"id"]
						ex = entity[?"x"]
						ey = entity[?"z"]
						ez = entity[?"y"]
						
						if (is_string(eid) && is_real(ex) && is_real(ey) && is_real(ez))
						{
							var script = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""));
							if (script > -1)
							{
								build_pos = point3D(ex, ey, ez)
								block_current = array3D_get(block_obj, build_size_z, ex, ey, ez)
								block_state_id_current = array3D_get(block_state_id, build_size_z, ex, ey, ez)
								script_execute(script, entity)
							}
						}
					}
					debug_timer_stop("res_load_scenery, Parse Tile Entities")
				}
			}
		}
		
		debug_timer_start()

		openerr = false
		
		// Free file buffer
		buffer_delete(buffer_current)
			
		load_stage = "blocks"
		
		// Clear old timelines
		if (scenery_tl_list = null)
			scenery_tl_list = ds_list_create()
		else
		{
			for (var i = 0; i < ds_list_size(scenery_tl_list); i++)
				with (scenery_tl_list[|i])
					instance_destroy()
			ds_list_clear(scenery_tl_list)
		}
		
		mc_builder.build_pos_x = 0
		mc_builder.build_pos_y = 0
		mc_builder.build_pos_z = 0
		mc_builder.block_tl_list = scenery_tl_list
			
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
			for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
				for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
					builder_set_model()
						
			build_pos_z++
		}
		
		if (mc_builder.build_pos_z = mc_builder.build_size_z)
		{
			debug_timer_stop("res_load_scenery, Set models")
			debug_timer_start()
			
			// Prepare vbuffers
			block_vbuffer_start()
		
			load_stage = "model"
			mc_builder.build_pos_z = 0
			
			with (app)
				popup_loading.text = text_get("loadscenerymodel")
		}
		else
			with (app)
				popup_loading.progress = 2 / 10 + (2 / 10) * (mc_builder.build_pos_z / mc_builder.build_size_z)
		
		break
	}
		
	// Generate model
	case "model":
	{
		with (mc_builder)
		{
			for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
				for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
					builder_generate()
					
			build_pos_z++
		}
		
		// All done
		if (mc_builder.build_pos_z = mc_builder.build_size_z)
		{
			debug_timer_stop("res_load_scenery, Generate models")
			block_vbuffer_done()
			mc_builder.block_tl_list = null
			
			if (dev_mode_rotate_blocks) // Rotate 90 degrees
				scenery_size = vec3(mc_builder.build_size_y, mc_builder.build_size_x, mc_builder.build_size_z)
			else
				scenery_size = vec3(mc_builder.build_size_x, mc_builder.build_size_y, mc_builder.build_size_z)
			ready = true

			// Put map name in resource name
			if (mc_builder.file_map != "")
			{
				display_name = text_get("loadscenerypieceof", mc_builder.file_map)
				if (type = "fromworld") // Rename world import file
				{
					type = "schematic"
					var newname = filename_get_unique(app.project_folder + "\\" + display_name + ".blocks"); // TODO exporter should use .schematic to support TileEntities & block states
					filename = filename_name(newname)
					display_name = filename_new_ext(filename, "")
					file_rename_lib(app.project_folder + "\\export.blocks", newname)
				}
			}
				
			// Update templates
			with (obj_template)
				if (scenery = other.id)
					temp_update_rot_point()
			
			// Update timelines
			with (obj_timeline)
				if (type = "scenery" && temp.scenery = other.id && scenery_animate)
					tl_animate_scenery()
			
			// Next
			with (app)
			{
				tl_update_matrix()
				load_next()
			}
		}
		else
			with (app)
				popup_loading.progress = 4 / 10 + (6 / 10) * (mc_builder.build_pos_z / mc_builder.build_size_z)
		
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