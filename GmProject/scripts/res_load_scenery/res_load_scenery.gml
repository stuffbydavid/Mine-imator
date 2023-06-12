/// res_load_scenery()
/// @desc Creates vertex buffers from a schematic or blocks file.
///		  The process is split into three steps for opening, reading and generating.
function res_load_scenery()
{
	var fname, openerr, rootmap;
	fname = load_folder + "/" + filename
	openerr = false
	rootmap = null
	var maxblocks = 20000 * thread_get_number();

	switch (load_stage)
	{
		// Open file
		case "open":
		{
			debug("res_load_scenery", "open")
			
			if (type = e_res_type.FROM_WORLD)
			{
				if (!res_load_scenery_world())
				{
					error("errorloadworld")
					with (app)
						load_next()
					ready = true
					break
				}
			}
			else
			{
				if (!file_exists_lib(fname))
				{
					with (app)
						load_next()
					return 0
				}
		
				// Schematic/Structure file
				var ext = filename_ext(fname);
				if (ext = ".schematic" || ext = ".nbt")
				{
					log("Loading " + ext, fname)
					debug_timer_start()
		
					// GZunzip
					file_delete_lib(temp_file)
					gzunzip(fname, temp_file)
			
					if (!file_exists_lib(temp_file))
					{
						log("GZunzip error", "gzunzip")
						break
					}
			
					buffer_current = buffer_load(temp_file)
					openerr = true
		
					// Read NBT structure
					rootmap = nbt_read_tag_compound();
					if (rootmap = null)
						break
				
					debug_timer_stop("res_load_scenery, Parse NBT")
			
					if (dev_mode_debug_schematics)
						nbt_debug_tag_compound("root", rootmap)
					
					// Parse blocks
					if (ext == ".schematic")
					{
						with (mc_builder)
						{
							openerr = !builder_read_schematic(rootmap[?"Schematic"])
							if (openerr)
								break;
						
							builder_read_schematic_blocks()
							builder_read_schematic_tile_entities()
						}
					}
					else // .nbt file (Structures)
					{
						openerr = !builder_read_schematic_nbt(rootmap[?""])
						if (openerr)
							break
					}
					
					if (openerr)
						break
				}
		
				// .blocks file (legacy)
				else 
				{
					log("Loading .blocks", fname)
			
					buffer_current = buffer_load_lib(fname)
					with (mc_builder)
						builder_read_blocks_file()
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
		
			with (app)
			{
				popup_loading.text = text_get("loadsceneryblocks")
				if (mc_builder.file_map != "")
					popup_loading.caption = text_get("loadscenerycaptionpieceof", mc_builder.file_map)
				else
					popup_loading.caption = text_get("loadscenerycaption", other.filename)
				popup_loading.progress = 2 / 10
			}
		
			// A null value will peform a check if block timelines should be added
			if (scenery_tl_add = null)
			{
				if (mc_builder.sch_timeline_amount > 500) // More than 500 timelines, always skip
					scenery_tl_add = false
				else if (mc_builder.sch_timeline_amount > 20) // More than 20 possible timelines, ask the user
					scenery_tl_add = question(text_get("loadsceneryaddtimelines", mc_builder.sch_timeline_amount))
				else // Less, always add
					scenery_tl_add = true
			}
		
			mc_builder.block_skull_texture_count = ds_map_size(mc_builder.block_skull_texture_map)
			mc_builder.block_skull_finish_count = 0
			mc_builder.block_skull_fail_count = 0
			mc_builder.build_pos_x = 0
			mc_builder.build_pos_y = 0
			mc_builder.build_pos_z = 0
			mc_builder.build_pos = 0
			mc_builder.block_tl_add = scenery_tl_add
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
				
				var blockstartpos = build_pos;
				var blockendpos = build_pos + maxblocks;
				if (blockendpos > build_size_total)
					blockendpos = build_size_total
				builder_spawn_threads(thread_get_number())
				
				/// CppOnly #pragma OPENMP_FOR
				for (var p = blockstartpos; p < blockendpos; p++)
				{
					with (thread_list[|thread_get_id()])
					{
						builder_thread_set_pos(p)
						builder_set_model()
					}
				}
				
				builder_combine_threads()
				build_pos = blockendpos
				
				builder_scenery = false
			}
		
			with (app)
				popup_loading.progress = 2 / 10 + (2 / 10) * (mc_builder.build_pos / mc_builder.build_size_total)
					
			if (mc_builder.build_pos = mc_builder.build_size_total)
			{
				debug_timer_stop("res_load_scenery, Set models")
				debug_timer_start()
			
				// Prepare vbuffers
				block_vbuffer_start()
		
				load_stage = "model"
				mc_builder.build_pos_z = 0
				mc_builder.build_pos = 0
			
				with (app)
					popup_loading.text = text_get("loadscenerymodel")
			}
		
			break
		}
		
		// Generate model
		case "model":
		{
			with (mc_builder)
			{
				builder_scenery = true
				build_multithreaded = true
				
				var blockstartpos = build_pos;
				var blockendpos = build_pos + maxblocks;
				if (blockendpos > build_size_total)
					blockendpos = build_size_total
				builder_spawn_threads(thread_get_number())
				
				/// CppOnly #pragma OPENMP_FOR
				for (var p = blockstartpos; p < blockendpos; p++)
				{
					with (thread_list[|thread_get_id()])
					{
						builder_thread_set_pos(p)
						builder_generate()
					}
				}
				
				builder_combine_threads()
				build_pos = blockendpos
				
				builder_scenery = false
			}
		
			with (app)
				popup_loading.progress = 4 / 10 + (6 / 10) * (mc_builder.build_pos / mc_builder.build_size_total)
					
			// All done
			if (mc_builder.build_pos = mc_builder.build_size_total)
			{
				// Non multi-threaded blocks
				with (mc_builder)
				{
					if (!block_multithreaded_skip)
						break;
						
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
					build_randomize = false
				}
			
				scenery_size = vec3(mc_builder.build_size_y, mc_builder.build_size_x, mc_builder.build_size_z)
				ready = true

				// Put map name in resource name
				if (mc_builder.file_map != "")
					display_name = text_get("loadscenerypieceof", mc_builder.file_map)
				
				// Save cached mesh
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
					if (type = e_temp_type.SCENERY && temp.scenery = other.id && scenery_animate)
						tl_animate_scenery()
			
				// Next
				with (app)
				{
					tl_update_list()
					tl_update_matrix()
					load_next()
				}
			}
		
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


}
