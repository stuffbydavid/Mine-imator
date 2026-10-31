/// @desc Creates vertex buffers from a schematic or blocks file.
/// The process is split into three steps for opening, reading and generating.
/// Force C++ generator to reduce types to int for OpenMP loops:
/// CppGen int blockstartpos
/// CppGen int blockendpos

function res_load_scenery()
{
	var fn, maxblocks;
	fn = load_folder + "/" + filename
	maxblocks = 20000 * thread_get_number()

	switch (load_stage)
	{
		// Open file
		case "open":
		{
			var err = false;
			res_load_scenery_filter_mask()
			
			// Load from world when requested or when the schematic is unavailable
			if (type = e_res_type.FROM_WORLD && (world_reload || !file_exists_lib(fn)))
			{
				world_reload = false
				scenery_instant = false
				
				if (!res_load_scenery_world())
				{
					error("error/load_world")
					err = true
				}
			}
			else
			{
				if (!file_exists_lib(fn))
					err = true

				// Load from valid schematic/blocks file
				else if (!res_load_scenery_file(fn))
				{
					error("error/load_schematic")
					err = true
				}
			}
			
			// Error
			if (err)
			{
				if (scenery_instant)
					load_stage = ""
				else
					with (app)
						load_next()
		
				ready = true
				return 0
			}
		
			debug_timer_start()

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

			for (var i = 0; i < array_length(mc_builder.sch_entities); i++)
			{
				var entitytype = mc_builder.sch_entities[i][scenery_entity_tl_type_index];
				if (entitytype = "")
					continue

				scenery_tl_types_count_map[?entitytype] = value_get_real(scenery_tl_types_count_map[?entitytype], 0) + 1
				mc_builder.sch_timeline_amount++
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
						var tltype, count;
						tltype = scenery_timeline_enabled[i]
						count = value_get_real(scenery_tl_types_count_map[?tltype], 0)
						if (count > 0 && count <= scenery_timeline_enabled_max)
							array_add(scenery_tl_types, tltype)
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
			if (ds_map_size(mc_builder.block_skull_texture_map) > 0 && mc_builder.block_tl_add && !scenery_instant)
			{
				res_load_skulls()
				break
			}

			// Finish download stage
			if (scenery_instant)
			{
				var key = ds_map_find_first(mc_builder.block_skull_texture_map);
				while (!is_undefined(key))
				{
					mc_builder.block_skull_res_map[?key] = null
					key = ds_map_find_next(mc_builder.block_skull_texture_map, key)
				}
			}
			else
			{
				with (app)
				{
					popup_loading.text = text_get("load_scenery/blocks")
					popup_loading.progress = 0.2
				}
			}

			load_stage = "blocks"

			if (mc_builder.block_skull_fail_count = 0)
				scenery_download_skins = false

			// Create entity timelines
			with (mc_builder)
			{
				for (var i = 0; i < array_length(sch_entities); i++)
				{
					var entity = sch_entities[i];
					if (entity[scenery_entity_tl_type_index] = "" || !block_tl_add)
						continue

					if (block_tl_types != null && !array_contains(block_tl_types, entity[scenery_entity_tl_type_index]))
						continue

					with (new_obj(obj_block_tl))
					{
						model_name = entity[0]
						model_state = entity[1]
						animated = false
						animated_parts = []
						position = vec3(entity[2][X] * block_size, entity[2][Y] * block_size, entity[2][Z] * block_size)
						rotation = entity[3]
						rot_point = entity[4]
						texture = null
						has_text = false
						pattern_type = ""

						ds_list_add(other.block_tl_list, id)
					}
				}
			}

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
				block_meshes_start(true)
		
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
			
			block_meshes_done()
			
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

				if (array_length(blocks_added) > 0 || array_length(block_meshes_edit) > 0)
					tl_update_block_meshes()
				
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
}
