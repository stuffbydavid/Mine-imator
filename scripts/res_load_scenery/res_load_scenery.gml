/// res_load_scenery()
/// @desc Creates vertex buffers from a schematic, structure, or blocks file.
///		  The process is split into three steps for opening, reading and generating.

function res_load_scenery()
{
	var fname, openerr, rootmap;
	fname = load_folder + "\\" + filename
	openerr = ""
	rootmap = null
	
	switch (load_stage)
	{
		// Open file
		case "open":
		{
			var timelineamount = 0;
			
			debug("res_load_scenery", "open")
			
			if (!file_exists_lib(fname))
			{
				with (app)
					load_next()
				return 0
			}
			
			// Schematic file
			if (filename_ext(fname) = ".schematic")
			{
				var paletteblocks, palettestateids, palettewaterlogged, blockdataarray, blockdataints;
				var legacy, legacyblocksarray, legacydataarray;
				
				log("Loading .schematic", fname)
				debug_timer_start()
				
				// GZunzip
				file_delete_lib(temp_file)
				gzunzip(fname, temp_file)
				
				if (!file_exists_lib(temp_file))
				{
					log("Schematic error", "gzunzip")
					break
				}
				
				buffer_current = buffer_load(temp_file)
				openerr = "errorloadschematic"
				
				// Read NBT structure
				rootmap = nbt_read_tag_compound();
				if (rootmap = null)
					break
				
				debug_timer_stop("res_load_scenery, Parse NBT")
				
				if (dev_mode_debug_schematics)
					nbt_debug_tag_compound("root", rootmap)
				
				// Get Schematic tag
				var schematicmap = rootmap[?"Schematic"];
				if (!ds_map_valid(schematicmap))
				{
					log("Schematic error", "Not a schematic file")
					break
				}
				
				// Get format
				legacy = is_undefined(schematicmap[?"Palette"])
				mc_builder.builder_scenery_legacy = legacy
				
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
				
				if (mc_builder.build_size[X] <= 0 || 
					mc_builder.build_size[Y] <= 0 || 
					mc_builder.build_size[Z] <= 0)
				{
					log("Schematic error", "Size cannot be 0")
					break
				}
				
				if (!legacy)
				{
					// Check version
					var version = schematicmap[?"Version"];
					if (is_undefined(version))
					{
						log("Schematic error", "Version not available")
						break
					}
					
					log("Version", schematicmap[?"Version"])
					if (version > 1)
					{
						log("Schematic error", "Unsupported format, version too high")
						break
					}
					
					// Get palette
					var palettemap = schematicmap[?"Palette"]
					if (!ds_map_valid(palettemap))
					{
						log("Schematic error", "Palette not found")
						break
					}
					
					// Create block & state ID lookup
					for (var i = 0; i < ds_map_size(palettemap); i++)
					{
						paletteblocks[i] = null
						palettestateids[i] = null
						palettewaterlogged[i] = false
					}
					
					var key = ds_map_find_first(palettemap);
					while (!is_undefined(key))
					{
						if (!string_contains(key, "_NBT_"))
						{
							var index, bracketindex;
							index = palettemap[?key]
							bracketindex = string_pos("[", key)
							
							// Has properties
							if (bracketindex > 0)
							{
								var mcid = string_copy(key, 1, bracketindex - 1);
								var varstr = string_copy(key, bracketindex + 1, string_length(key) - 1 - bracketindex);
								var block = mc_assets.block_id_map[?mcid]
								if (!is_undefined(block))
								{
									var vars = array();
									
									// ID specific vars
									if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?mcid]))
										state_vars_add(vars, block.id_state_vars_map[?mcid])
									
									// Properties vars
									state_vars_add(vars, string_get_state_vars(varstr))
									
									paletteblocks[index] = block
									palettestateids[index] = block_get_state_id(block, vars)
									
									// Check waterlogged status
									if (state_vars_get_value(vars, "waterlogged") != "false")
										if (block.waterlogged || state_vars_get_value(vars, "waterlogged") = "true")
											palettewaterlogged[index] = true
								}
							}
							
							// ID only
							else if (!is_undefined(mc_assets.block_id_map[?key]))
							{
								var block = mc_assets.block_id_map[?key]
								paletteblocks[index] = block
								
								// ID specific vars
								if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?key]))
									palettestateids[index] = block_get_state_id(block, block.id_state_vars_map[?key])
								else
									palettestateids[index] = 0
								
								palettewaterlogged[index] = block.waterlogged
							}
						}
						
						key = ds_map_find_next(palettemap, key)
					}
					
					// Get block array
					blockdataarray = schematicmap[?"BlockData"]
					if (is_undefined(blockdataarray))
					{
						log("Schematic error", "BlockData array not found")
						break
					}
					
					blockdataints = (schematicmap[?"BlockData_NBT_type"] = e_nbt.TAG_INT_ARRAY)
					debug("blockdataints", blockdataints)
					
					// Get map
					var metadata = schematicmap[?"Metadata"]
					if (ds_map_valid(metadata))
						mc_builder.file_map = metadata[?"FromMap"]
				}
				else
				{
					// Get block/data array
					legacyblocksarray = schematicmap[?"Blocks"];
					if (is_undefined(legacyblocksarray))
					{
						log("Schematic error", "Blocks array not found")
						break
					}
					
					legacydataarray = schematicmap[?"Data"];
					if (is_undefined(legacydataarray))
					{
						log("Schematic error", "Data array not found")
						break
					}
					
					// Get map
					mc_builder.file_map = schematicmap[?"FromMap"]
				}
				
				if (is_undefined(mc_builder.file_map))
					mc_builder.file_map = ""
				
				// Parse blocks
				with (mc_builder)
				{
					debug_timer_start()
					builder_start()
					
					buffer_seek(block_obj, buffer_seek_start, 0)
					buffer_seek(block_state_id, buffer_seek_start, 0)
					buffer_seek(block_waterlogged, buffer_seek_start, 0)
					
					var i = 0;
					for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
					{
						for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
						{
							for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
							{
								var block, stateid, waterlogged;
								block = null
								stateid = null
								waterlogged = false
								
								if (!legacy)
								{
									// Read index
									var bindex;
									if (blockdataints)
									{
										buffer_seek(buffer_current, buffer_seek_start, blockdataarray + i * 4)
										bindex = buffer_read_int_be()
									}
									else
										bindex = buffer_peek(buffer_current, blockdataarray + i, buffer_u8)
									
									if (bindex > 0)
									{
										block = paletteblocks[bindex]
										stateid = palettestateids[bindex]
										waterlogged = palettewaterlogged[bindex]
									}
								}
								else
								{
									// Read legacy block ID & data
									var bid = buffer_peek(buffer_current, legacyblocksarray + i, buffer_u8)
									if (bid > 0 && legacy_block_set[bid])
									{
										var bdata = buffer_peek(buffer_current, legacydataarray + i, buffer_u8);
										block = legacy_block_obj[bid, bdata]
										stateid = legacy_block_state_id[bid, bdata]
									}
								}
								
								if (block != null && block.timeline)
									timelineamount++
								
								buffer_write(block_obj, buffer_s32, block)
								buffer_write(block_state_id, buffer_s32, stateid)
								buffer_write(block_waterlogged, buffer_u8, waterlogged)
								i++
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
							
							if (!legacy)
							{
								eid = entity[?"Id"]
								var poslist = entity[?"Pos"];
								buffer_seek(buffer_current, buffer_seek_start, poslist)
								ex = buffer_read_int_be()
								ez = buffer_read_int_be()
								ey = buffer_read_int_be()
							}
							else
							{
								eid = entity[?"id"]
								ex = entity[?"x"]
								ey = entity[?"z"]
								ez = entity[?"y"]
							}
							
							if (is_string(eid) && is_real(ex) && is_real(ey) && is_real(ez))
							{
								var script = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""));
								if (script > -1)
								{
									build_pos_x = ex
									build_pos_y = ey
									build_pos_z = ez
									block_current = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z)
									block_state_id_current = builder_get(block_state_id, build_pos_x, build_pos_y, build_pos_z)
									script_execute(script, entity)
								}
							}
						}
						debug_timer_stop("res_load_scenery, Parse Tile Entities")
					}
				}
			}
			else if (filename_ext(fname) = ".nbt") // .nbt file (Structures)
			{
				var structuremap, structureversion, sizemap;
				
				scenery_structure = true
				
				log("Loading .nbt", fname)
				debug_timer_start()
				
				// GZunzip
				file_delete_lib(temp_file)
				gzunzip(fname, temp_file)
				
				if (!file_exists_lib(temp_file))
				{
					log("Structure error", "gzunzip")
					break
				}
				
				buffer_current = buffer_load(temp_file)
				openerr = "errorloadscenery"
				
				// Read NBT structure
				rootmap = nbt_read_tag_compound()
				if (rootmap = null)
					break
				
				debug_timer_stop("res_load_scenery, Parse NBT")
				
				structuremap = rootmap[?""]
				
				// Check DataVersion tag
				structureversion = 1
				
				if (!is_undefined(structuremap[?"DataVersion"]))
					structureversion = structuremap[?"DataVersion"]
				
				if (structureversion < 2000)
				{
					log("Structure error", "Unsupported format, version too low")
					break
				}
				
				// Get size
				sizemap = structuremap[?"size"]
				mc_builder.build_size[X] = sizemap[|X]
				mc_builder.build_size[Y] = sizemap[|Z]
				mc_builder.build_size[Z] = sizemap[|Y]
				log("Size", mc_builder.build_size)
				
				if (mc_builder.build_size[X] <= 0 || 
					mc_builder.build_size[Y] <= 0 || 
					mc_builder.build_size[Z] <= 0)
				{
					log("Structure error", "Size cannot be 0")
					break
				}
				
				// Get palette
				var paletteslist, palettelist;
				paletteslist = structuremap[?"palettes"]
				
				// Pick random palette from list or use single palette
				if (ds_list_valid(paletteslist))
				{
					scenery_palette_size = ds_list_size(paletteslist)
					palettelist = paletteslist[|scenery_palette mod scenery_palette_size]
				}
				else
				{
					palettelist = structuremap[?"palette"]
					if (!ds_list_valid(palettelist))
					{
						log("Structure error", "Palette not found")
						break
					}
				}	
				
				// Create block & state ID lookup
				for (var i = 0; i < ds_list_size(palettelist); i++)
				{
					paletteblocks[i] = null
					palettestateids[i] = null
					palettewaterlogged[i] = false
				}
				
				// Read palette
				for (var i = 0; i < ds_list_size(palettelist); i++)
				{
					var block, blockmap, mcid, propertiesmap, propertiesarr, key;
					blockmap = palettelist[|i]
					mcid = blockmap[?"Name"]
					block = mc_assets.block_id_map[?mcid]
					propertiesarr = null
					
					if (!is_undefined(block))
					{
						var vars = array();
						
						// ID specific vars
						if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?mcid]))
							state_vars_add(vars, block.id_state_vars_map[?mcid])
						
						// Read Properties tag
						propertiesmap = blockmap[?"Properties"]
						if (!is_undefined(propertiesmap))
						{
							key = ds_map_find_first(propertiesmap)
							
							// Build properties array from map keys and values
							var index = 0;
							for (var j = 0; j < ds_map_size(propertiesmap); j++)
							{
								if (!string_contains(key, "_NBT_"))
								{
									propertiesarr[index * 2] = key
									propertiesarr[index * 2 + 1] = propertiesmap[?key]
									index++
								}
								
								key = ds_map_find_next(propertiesmap, key)
							}
						}
						
						// Properties vars
						state_vars_add(vars, propertiesarr)
						
						paletteblocks[i] = block
						palettestateids[i] = block_get_state_id(block, vars)
						
						// Check waterlogged status
						if (state_vars_get_value(vars, "waterlogged") != "false")
							if (block.waterlogged || state_vars_get_value(vars, "waterlogged") = "true")
								palettewaterlogged[i] = true
					}
				}
				
				// Get block list
				var blocklist = structuremap[?"blocks"]
				if (!ds_list_valid(blocklist))
				{
					log("Structure error", "Block list not found")
					break
				}
				
				// Parse blocks states
				with (mc_builder)
				{
					debug_timer_start()
					builder_start()
					
					buffer_seek(block_obj, buffer_seek_start, 0)
					buffer_seek(block_state_id, buffer_seek_start, 0)
					buffer_seek(block_waterlogged, buffer_seek_start, 0)
					
					// Fill with default values
					buffer_fill(block_obj, 0, buffer_s32, null, build_size_total * 4)
					buffer_fill(block_state_id, 0, buffer_s32, null, build_size_total * 4)
					buffer_fill(block_waterlogged, 0, buffer_u8, false, build_size_total)
					
					for (var i = 0; i < ds_list_size(blocklist); i++)
					{
						var blockmap, pos, state, index, block, stateid, waterlogged, entity, blocknbt;
						blockmap = blocklist[|i]
						pos = blockmap[?"pos"]
						state = blockmap[?"state"]
						index = builder_get_index(pos[|X], pos[|Z], pos[|Y])
						
						block = paletteblocks[state]
						stateid = palettestateids[state]
						waterlogged = palettewaterlogged[state]
						entity = null
						
						// Integrity test
						random_set_seed(index)
						
						if (other.scenery_integrity_invert)
						{
							if (random(1) < other.scenery_integrity)
								continue
						}
						else
						{
							if (random(1) > other.scenery_integrity)
								continue
						}
						
						// Tile entity/jigsaw
						blocknbt = blockmap[?"nbt"];
						if (!is_undefined(blocknbt))
						{
							var finalstate, eid, script;
							finalstate = blocknbt[?"final_state"]
							
							if (!is_undefined(finalstate))
							{
								// Replace jigsaw with final_state value
								block = mc_assets.block_id_map[?finalstate]
								
								if (is_undefined(block))
									continue
								
								var vars = array();
								
								// ID specific vars
								if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?finalstate]))
									state_vars_add(vars, block.id_state_vars_map[?finalstate])
								
								stateid = block_get_state_id(block, vars)
							}
							else
								entity = blocknbt[?"id"]
						}
						
						buffer_poke(block_obj, index * 4, buffer_s32, block)
						buffer_poke(block_state_id, index * 4, buffer_s32, stateid)
						buffer_poke(block_waterlogged, index, buffer_u8, waterlogged)
						
						// Execute tile entity script
						if (entity != null)
						{
							script = asset_get_index("block_tile_entity_" + string_replace(string_lower(entity), "minecraft:", ""))
							if (script > -1)
							{
								build_pos_x = pos[|X]
								build_pos_y = pos[|Z]
								build_pos_z = pos[|Y]
								block_current = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z)
								block_state_id_current = builder_get(block_state_id, build_pos_x, build_pos_y, build_pos_z)
								script_execute(script, blocknbt)
							}
						}
					}
				}
				
				debug_timer_stop("res_load_scenery, Parse blocks")
			}
			// .blocks file (legacy)
			else 
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
					log("Size", build_size)
					
					builder_start()
					
					buffer_seek(block_obj, buffer_seek_start, 0)
					buffer_seek(block_state_id, buffer_seek_start, 0)
				
					for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
					{
						for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
						{
							for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
							{
								var block, stateid, bid, bdata;
								block = null
								stateid = null
								
								// Read legacy block ID & data
								bid = buffer_read_byte()
								bdata = buffer_read_byte()
								if (bid > 0)
								{
									block = legacy_block_obj[bid, bdata]
									stateid = legacy_block_state_id[bid, bdata]
									if (block != null && block.timeline)
										timelineamount++
								}
								
								buffer_write(block_obj, buffer_s32, block)
								buffer_write(block_state_id, buffer_s32, stateid)
							}
						}
					}
				}
				debug_timer_stop("res_load_scenery: Loaded .blocks")
			}
			
			debug_timer_start()
			
			openerr = ""
			
			// Free file buffer
			buffer_delete(buffer_current)
			
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
			
			// A null value will peform a check if block timelines should be added
			if (scenery_tl_add = null)
			{
				if (timelineamount > 20) // More than 20 possible timelines, ask the user
					scenery_tl_add = question(text_get("loadsceneryaddtimelines", timelineamount))
				else // Less, always add
					scenery_tl_add = true
			}
			
			if (mc_builder.file_map != "")
				app.popup_loading.caption = text_get("loadscenerycaptionpieceof", mc_builder.file_map)
			else
				app.popup_loading.caption = text_get("loadscenerycaption", filename)
			
			mc_builder.block_skull_texture_count = ds_map_size(mc_builder.block_skull_texture_map)
			mc_builder.block_skull_finish_count = 0
			mc_builder.block_skull_fail_count = 0
			load_stage = "download"
			
			mc_builder.build_pos_x = 0
			mc_builder.build_pos_y = 0
			mc_builder.build_pos_z = 0
			mc_builder.block_tl_add = scenery_tl_add
			mc_builder.block_tl_list = scenery_tl_list
			break
		}
		
		// Download skins for custom skulls
		case "download":
		{	
			// Finished
			if (ds_map_size(mc_builder.block_skull_texture_map) = 0 || !mc_builder.block_tl_add)
			{
				with (app)
				{
					popup_loading.text = text_get("loadsceneryblocks")
					popup_loading.progress = 2 / 10
				}
				
				load_stage = "blocks"
				
				if (mc_builder.block_skull_fail_count = 0)
					scenery_download_skins = false
				
				break
			}
			
			app.popup_loading.text = text_get("loadscenerydownload", mc_builder.block_skull_finish_count, mc_builder.block_skull_texture_count, mc_builder.block_skull_fail_count)
			
			// Continue through texture list
			with (mc_builder)
			{
				var nexttex = false;
				
				if (block_skull_download_wait = false)
				{
					block_skull_texture_name = ds_map_find_first(block_skull_texture_map)
					
					// Check if the skin already exists in the project
					var exists = false;
					
					with (obj_resource)
					{
						if (type = e_res_type.DOWNLOADED_SKIN && filename = (skins_directory + mc_builder.block_skull_texture_name + ".png"))
						{
							mc_builder.block_skull_res_map[?mc_builder.block_skull_texture_name] = id
							exists = true
							nexttex = true
							break
						}
					}
					
					// Resource doesn't exist, download texture
					if (exists = false && other.scenery_download_skins)
					{
						app.http_downloadskin = http_get_file(ds_map_find_value(block_skull_texture_map, block_skull_texture_name), download_image_file)
						block_skull_download_time = current_time
						block_skull_download_wait = true
					}
				}
				
				// Clear current texture in list (If downloaded or failed.)
				if (block_skull_texture != null || block_skull_texture_fail = true || (current_time - block_skull_download_time > 3000))
				{
					// Create new resource with downloaded texture
					if (block_skull_texture != null)
					{
						var res = null;
						
						// Use existing skin resource
						with (obj_resource)
						{
							if (filename_name(mc_builder.block_skull_texture_name) = filename_change_ext(filename, ""))
							{
								res = id
								break
							}
						}
						
						// Create new skin resource
						if (res = null)
						{
							with (app)
							{
								directory_create_lib(skins_directory)
								var fn = skins_directory + mc_builder.block_skull_texture_name + ".png"
								file_copy_lib(download_image_file, fn)
								
								res = new_res(fn, e_res_type.DOWNLOADED_SKIN)
								res.player_skin = true
								
								with (res)
									res_load()
							}
						}
						
						block_skull_res_map[?block_skull_texture_name] = res
					}
					else
					{
						block_skull_res_map[?block_skull_texture_name] = null
						log("Failed to download texture", block_skull_texture_name)
						block_skull_fail_count++
					}
					
					block_skull_finish_count++
					nexttex = true
				}
				
				// Remove current texture and continue
				if (nexttex)
				{
					ds_map_delete(block_skull_texture_map, ds_map_find_first(block_skull_texture_map))
					block_skull_texture = null
					block_skull_texture_fail = false
					block_skull_download_wait = false
				}
			}
			
			break
		}
		
		// Read blocks
		case "blocks":
		{
			mc_builder.builder_scenery = true
			
			// Set models
			with (mc_builder)
			{
				for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
					for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
						builder_set_model()
					
				build_pos_z++
			}
			mc_builder.builder_scenery = false
			
			if (mc_builder.build_pos_z = mc_builder.build_size_z)
			{
				debug_timer_stop("res_load_scenery, Set models")
				debug_timer_start()
				
				// Prepare vbuffers
				block_vbuffer_start(point3D(mc_builder.build_size_x, mc_builder.build_size_y, mc_builder.build_size_z))
				
				mc_builder.build_pos_z = 0
				
				app.popup_loading.text = text_get("loadscenerymodel")
				load_stage = "model"
			}
			else
				with (app)
					popup_loading.progress = 2 / 10 + (2 / 10) * (mc_builder.build_pos_z / mc_builder.build_size_z)
			
			break
		}
		
		// Generate model
		case "model":
		{
			// Force garbage collection to keep memory 'low'
			gc_collect()
			
			mc_builder.builder_scenery = true
			with (mc_builder)
			{
				for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
					for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
						builder_generate()
				
				build_pos_z++
			}
			mc_builder.builder_scenery = false
			
			// All done
			if (mc_builder.build_pos_z = mc_builder.build_size_z)
			{
				debug_timer_stop("res_load_scenery, Generate models")
				block_vbuffer_done()
				
				with (mc_builder)
				{
					builder_done()
					block_tl_list = null
				}
				
				if (!dev_mode || dev_mode_rotate_blocks) // Rotate 90 degrees
					scenery_size = vec3(mc_builder.build_size_y, mc_builder.build_size_x, mc_builder.build_size_z)
				else
					scenery_size = vec3(mc_builder.build_size_x, mc_builder.build_size_y, mc_builder.build_size_z)
				ready = true
				
				// Put map name in resource name
				if (mc_builder.file_map != "")
				{
					display_name = text_get("loadscenerypieceof", mc_builder.file_map)
					if (type = e_res_type.FROM_WORLD) // Rename world import file
					{
						type = e_res_type.SCENERY
						var newname = filename_get_unique(app.project_folder + "\\" + display_name + ".schematic");
						filename = filename_name(newname)
						display_name = filename_new_ext(filename, "")
						file_rename_lib(app.project_folder + "\\world.schematic", newname)
					}
				}
				
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
			else
				with (app)
					popup_loading.progress = 4 / 10 + (6 / 10) * (mc_builder.build_pos_z / mc_builder.build_size_z)
			
			break
		}
	}
	
	if (rootmap != null)
		ds_map_destroy(rootmap)
	
	// Scenery error
	if (openerr != "")
	{
		error(openerr)
		buffer_delete(buffer_current)
		with (app)
			load_next()
	}
}
