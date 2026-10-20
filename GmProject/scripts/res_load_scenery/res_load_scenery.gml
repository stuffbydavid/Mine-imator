/// @desc Creates vertex buffers from a schematic or blocks file.
/// The process is split into three steps for opening, reading and generating.
/// Force C++ generator to reduce types to int for OpenMP loops:
/// CppGen int blockstartpos
/// CppGen int blockendpos

function res_load_scenery()
{
	var fn, openerr, rootmap, maxblocks;
	fn = load_folder + "/" + filename
	openerr = false
	rootmap = null
	maxblocks = 20000 * thread_get_number()

	switch (load_stage)
	{
		// Open file
		case "open":
		{
			res_load_scenery_filter_mask()

			// Load from world when requested or when the schematic is unavailable
			if (type = e_res_type.FROM_WORLD && (world_reload || !file_exists_lib(fn)))
			{
				world_reload = false
				
				if (!res_load_scenery_world())
				{
					error("error/load_world")
					
					with (app)
						load_next()
					
					ready = true
					
					break
				}
			}
			else
			{
				if (!file_exists_lib(fn))
				{
					if (scenery_instant)
						load_stage = ""
					else
						with (app)
							load_next()
					
					ready = true
					
					return 0
				}
		
				// Schematic/Structure file
				var ext = filename_ext(fn);
				if (ext = ".schematic" || ext = ".schem" || ext = ".nbt" || ext = ".litematic")
				{
					log("Loading " + ext, fn)
					debug_timer_start()
		
					// GZunzip
					file_delete_lib(temp_file)
					gzunzip(fn, temp_file)
			
					if (!file_exists_lib(temp_file))
					{
						log("GZunzip error", "gzunzip")
						error("error/load_schematic")
						
						if (scenery_instant)
							load_stage = ""
						else
							with (app)
								load_next()
						
						ready = true
						
						return 0
					}
			
					buffer_current = buffer_load(temp_file)
					openerr = true
		
					// Read NBT structure
					rootmap = nbt_read_tag_compound()
					if (rootmap = null)
						break
				
					debug_timer_stop("res_load_scenery, Parse NBT")
			
					if (debug_schematics)
						nbt_debug_tag_compound("root", rootmap)
					
					// Accept named, nested and unnamed schematic roots
					var schematicmap = rootmap[?"Schematic"];
					if (!ds_map_valid(schematicmap))
					{
						schematicmap = rootmap[?""]
						if (ds_map_valid(schematicmap) && ds_map_valid(schematicmap[?"Schematic"]))
							schematicmap = schematicmap[?"Schematic"]
					}

					// Read Litematic file
					if (ds_map_valid(schematicmap) && ds_map_valid(schematicmap[?"Regions"]))
						openerr = !builder_read_litematic(schematicmap)
					
					// Structure palettes use lowercase lists rather than Sponge compounds
					else if (ds_map_valid(schematicmap) && ds_list_valid(schematicmap[?"size"]))
					{
						openerr = !builder_read_nbt(schematicmap)
						if (openerr)
							break
					}
					else
					{
						scenery_structure = false
						scenery_palette_size = 0
						
						with (mc_builder)
						{
							openerr = !builder_read_schematic(schematicmap)
							if (openerr)
								break
						
							builder_read_schematic_blocks()
							
							with (other.id)
								res_load_scenery_block_map()
							
							builder_read_schematic_tile_entities()
						}
					}
					
					if (openerr)
						break
				}
		
				// .blocks file (legacy)
				else 
				{
					log("Loading .blocks", fn)
			
					buffer_current = buffer_load_lib(fn)
					with (mc_builder)
						builder_read_blocks_file()

					res_load_scenery_block_map()
				}
				
				// Free file buffer
				buffer_delete(buffer_current)
			}
		
			debug_timer_start()

			openerr = false
			load_stage = "download"
		
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
		
			if (!scenery_instant)
			{
				with (app)
				{
					popup_loading.text = text_get("load_scenery/blocks")
					
					if (other.type = e_res_type.FROM_WORLD)
						popup_loading.caption = other.world_name
					else if (mc_builder.file_map != "")
						popup_loading.caption = text_get("load_scenery/caption_piece_of", mc_builder.file_map)
					else
						popup_loading.caption = text_get("load_scenery/caption", other.filename)
					
					popup_loading.progress = 0.2
				}
			}
			
			// Set animation choices for new resources
			if (!scenery_tl_set)
			{
				scenery_tl_set = true
				
				// Enable all timelines for small scenery
				scenery_tl_all_types = (mc_builder.sch_timeline_amount <= scenery_timeline_prompt)
				scenery_tl_types = []
				
				if (!scenery_tl_all_types)
				{
					// Enable specific timelines only
					for (var i = 0; i < array_length(scenery_timeline_enabled); i++)
					{
						var type, count;
						type = scenery_timeline_enabled[i]
						count = value_get_real(scenery_tl_types_count_map[?type], 0)
						if (count > 0 && count <= 10)
							array_add(scenery_tl_types, type)
					}
					
					// Show popup
					if (!ds_map_empty(scenery_tl_types_count_map) && creator != app.bench_settings)
					{
						if (scenery_instant)
						{
							scenery_instant = false
							with (app)
							{
								ds_priority_add(load_queue, other.id, 1)
								load_start(other.id, res_load_scenery)
								popup_loading.progress = 0.2
							}
						}

						with (app)
							popup_block_settings_show(other.id, true)
					}
				}
			}
		
			mc_builder.block_skull_texture_count = ds_map_size(mc_builder.block_skull_texture_map)
			mc_builder.block_skull_finish_count = 0
			mc_builder.block_skull_fail_count = 0
			mc_builder.build_pos = vec3(0)
			mc_builder.build_pos_index = 0
			mc_builder.block_tl_add = (scenery_tl_all_types || array_length(scenery_tl_types) > 0)
			mc_builder.block_tl_types = res_get_block_timeline_types()
			mc_builder.block_tl_list = scenery_tl_list
			mc_builder.build_randomize = scenery_randomize
			
			break
		}
		
		// Download skins for custom skulls
		case "download":
		{
			res_load_skulls()
			break
		}
		
		// Read blocks
		case "blocks":
		{
			// Set models
			with (mc_builder)
			{
				builder_scenery = true
				
				var blockstartpos = build_pos_index;
				var blockendpos = build_pos_index + maxblocks;
				if (blockendpos > build_size_total)
					blockendpos = build_size_total
				
				builder_spawn_threads(thread_get_number())
				
				/// CppOnly #pragma OPENMP_FOR(16)
				for (var p = blockstartpos; p < blockendpos; p++)
				{
					with (thread_list[|thread_get_id()])
					{
						builder_thread_set_pos(p)
						builder_set_model()
					}
				}
				
				builder_combine_threads()
				
				build_pos_index = blockendpos
				
				builder_scenery = false
			}
		
			if (!scenery_instant)
				with (app)
					popup_loading.progress = 0.2 + (0.2) * (mc_builder.build_pos_index / mc_builder.build_size_total)
					
			if (mc_builder.build_pos_index = mc_builder.build_size_total)
			{
				debug_timer_stop("res_load_scenery, Set models")
				debug_timer_start()
			
				// Prepare vbuffers
				block_vbuffer_start()
		
				load_stage = "model"
				
				mc_builder.build_pos[Z] = 0
				mc_builder.build_pos_index = 0
			
				if (!scenery_instant)
					with (app)
						popup_loading.text = text_get("load_scenery/model")
			}
		
			break
		}
		
		// Generate model
		case "model":
		{
			with (mc_builder)
			{
				builder_scenery = true
				build_transform = true
				build_multithreaded = true
				
				var blockstartpos = build_pos_index;
				var blockendpos = build_pos_index + maxblocks;
				if (blockendpos > build_size_total)
					blockendpos = build_size_total
				builder_spawn_threads(thread_get_number())
				
				/// CppOnly #pragma OPENMP_FOR(16)
				for (var p = blockstartpos; p < blockendpos; p++)
				{
					with (thread_list[|thread_get_id()])
					{
						builder_thread_set_pos(p)
						builder_generate()
					}
				}
				
				builder_combine_threads()
				
				build_pos_index = blockendpos
				
				builder_scenery = false
			}
		
			if (!scenery_instant)
				with (app)
					popup_loading.progress = 0.4 + 0.5 * (mc_builder.build_pos_index / mc_builder.build_size_total)
					
			// All done
			if (mc_builder.build_pos_index = mc_builder.build_size_total)
				load_stage = "done"
			
			break
		}
		
		// Finish schematic and update project
		case "done":
		{
			// Non multi-threaded blocks
			with (mc_builder)
			{
				if (!block_multithreaded_skip)
					break
						
				build_transform = true
				build_multithreaded = false
				
				builder_spawn_threads(1)
				
				with (thread_list[|0])
				{
					for (var p = 0; p < build_size_total; p++)
					{
						builder_thread_set_pos(p)
						builder_generate()
					}
				}
				
				builder_combine_threads()
			}
				
			debug_timer_stop("res_load_scenery, Generate models")
			
			block_vbuffer_done()
			
			with (mc_builder)
			{
				builder_done()
				
				block_tl_list = null
				block_tl_types = null
				build_randomize = false
			}
			
			scenery_size = vec3(mc_builder.build_size[Y], mc_builder.build_size[X], mc_builder.build_size[Z])
			ready = true

			// Put map name in resource name
			if (type = e_res_type.FROM_WORLD)
				res_update_display_name()
			else if (mc_builder.file_map != "")
				display_name = text_get("load_scenery/piece_of", mc_builder.file_map)
				
			// Save cached mesh
			if (creator != app.bench_settings)
				res_save_block_cache(app.project_folder + "/" + filename + ".meshcache")
			
			// Update templates
			with (obj_template)
			{
				if (scenery = other.id)
				{
					temp_update_display_name()
					temp_update_rot_point()
				}
			}
			
			// Update timelines
			with (obj_timeline)
			{
				if (type != e_tl_type.SCENERY || temp.scenery != other.id)
					continue
				
				if (scenery_ground_hobj != null)
					tl_replace_ground(scenery_ground_hobj)
				
				if (scenery_animate)
					tl_animate_scenery()
			}
			
			
			with (app)
			{
				tl_update_list()
				tl_update_matrix()
				
				project_update_counts()
				
				lib_preview.update = true
				res_preview.update = true
				
				bench_settings.preview.update = true
				popup_loading.progress = 1
			}
			
			load_stage = scenery_instant ? "" : "next"
			
			break
		}
		
		// Next resource
		case "next":
		{
			with (app)
				load_next()
			
			break
		}
	}

	if (rootmap != null)
		ds_map_destroy(rootmap)

	// Schematic error
	if (openerr)
	{
		error("error/load_schematic")
		
		buffer_delete(buffer_current)
		
		if (scenery_instant)
			load_stage = ""
		else
			with (app)
				load_next()
		
		ready = true
	}
}
