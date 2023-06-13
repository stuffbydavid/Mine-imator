// Read a .schematic file, returns whether successful
function builder_read_schematic(map)
{
	if (!ds_map_valid(map))
	{
		log("Schematic error", "Not a schematic file")
		return false
	}
	
	// Get format
	builder_scenery_legacy = is_undefined(map[?"Palette"])
	
	// Get size
	build_size_x = map[?"Width"]
	build_size_y = map[?"Length"]
	build_size_z = map[?"Height"]
	log("Size", string(build_size_x) + " x " + string(build_size_y) + " x " + string(build_size_z))
	
	if (is_undefined(build_size_x) || 
		is_undefined(build_size_y) || 
		is_undefined(build_size_z))
	{
		log("Schematic error", "Size not fully defined")
		return false
	}
	
	if (build_size_x <= 0 || 
		build_size_y <= 0 || 
		build_size_z <= 0)
	{
		log("Schematic error", "Size cannot be 0")
		return false
	}
	
	if (!builder_scenery_legacy)
	{
		// Check version
		var version = map[?"Version"];
		if (is_undefined(version))
		{
			log("Schematic error", "Version not available")
			return false
		}
		
		log("Version", map[?"Version"])
		if (version > 1)
		{
			log("Schematic error", "Unsupported format, version too high")
			return false
		}
		
		// Get palette
		var palettemap = map[?"Palette"]
		if (!ds_map_valid(palettemap))
		{
			log("Schematic error", "Palette not found")
			return false
		}
		
		// Create block & state ID lookup
		for (var i = 0; i < ds_map_size(palettemap); i++)
		{
			sch_palette_blocks[i] = null
			sch_palette_stateids[i] = null
			sch_palette_waterlogged[i] = false
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
						
						sch_palette_blocks[index] = block
						sch_palette_stateids[index] = block_get_state_id(block, vars)
						
						// Check waterlogged status 
						if (state_vars_get_value(vars, "waterlogged") != "false") 
							if (block.waterlogged || state_vars_get_value(vars, "waterlogged") = "true") 
								sch_palette_waterlogged[index] = true 
					}
				}
				
				// ID only
				else if (!is_undefined(mc_assets.block_id_map[?key]))
				{
					var block = mc_assets.block_id_map[?key]
					sch_palette_blocks[index] = block
							
					// ID specific vars
					if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?key]))
						sch_palette_stateids[index] = block_get_state_id(block, block.id_state_vars_map[?key])
					else
						sch_palette_stateids[index] = 0
							
					sch_palette_waterlogged[index] = block.waterlogged
				}
			}
					
			key = ds_map_find_next(palettemap, key)
		}
		
		// Get block array
		sch_blockdata_array = map[?"BlockData"]
		if (is_undefined(sch_blockdata_array))
		{
			log("Schematic error", "BlockData array not found")
			return false
		}
		
		sch_blockdata_ints = (map[?"BlockData_NBT_type"] = e_nbt.TAG_INT_ARRAY)
		debug("blockdataints", sch_blockdata_ints)
		
		// Get map
		var metadata = map[?"Metadata"]
		if (ds_map_valid(metadata))
			file_map = metadata[?"FromMap"]
	}
	else
	{
		// Get block/data array
		sch_legacy_blocksarray = map[?"Blocks"];
		if (is_undefined(sch_legacy_blocksarray))
		{
			log("Schematic error", "Blocks array not found")
			return false
		}
		
		sch_legacy_dataarray = map[?"Data"];
		if (is_undefined(sch_legacy_dataarray))
		{
			log("Schematic error", "Data array not found")
			return false
		}
		
		// Get map
		file_map = map[?"FromMap"]
	}
			
	if (is_undefined(file_map))
		file_map = ""
		
	sch_tileentity_list = map[?"TileEntities"];
	
	return true
}

function builder_read_schematic_nbt(structuremap)
{
	var structureversion, sizemap;
	scenery_structure = true
				
	// Check DataVersion tag
	structureversion = 1
				
	if (!is_undefined(structuremap[?"DataVersion"]))
		structureversion = structuremap[?"DataVersion"]
				
	if (structureversion < 2000)
	{
		log("Structure error", "Unsupported format, version too low")
		return false
	}
				
	// Get size
	sizemap = structuremap[?"size"]
	mc_builder.build_size_x = sizemap[|X]
	mc_builder.build_size_y = sizemap[|Z]
	mc_builder.build_size_z = sizemap[|Y]
	log("Size", [mc_builder.build_size_x, mc_builder.build_size_y, mc_builder.build_size_z])
				
	if (mc_builder.build_size_x <= 0 || 
		mc_builder.build_size_y <= 0 || 
		mc_builder.build_size_z <= 0)
	{
		log("Structure error", "Size cannot be 0")
		return false
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
			return false
		}
	}	
	
	var paletteblocks, palettestateids, palettewaterlogged;
	
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
		return false
	}
				
	// Parse blocks states
	with (mc_builder)
	{
		debug_timer_start()
		builder_start()
		
		for (var i = 0; i < ds_list_size(blocklist); i++)
		{
			var blockmap, pos, state, index, block, stateid, waterlogged, entity, blocknbt;
			blockmap = blocklist[|i]
			pos = blockmap[?"pos"]
			state = blockmap[?"state"]
			index = pos[|Y] * sizemap[|X] * sizemap[|Z] + pos[|Z] * sizemap[|X] + pos[|X]
						
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
				var finalstate, script;
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
			
			if (block != null)
			{
				buffer_poke(block_obj, index * 2, buffer_u16, block.block_id)
				buffer_poke(block_state_id, index * 2, buffer_u16, stateid)
				buffer_poke(block_waterlogged, index, buffer_u8, waterlogged)
			}
			
			// Execute tile entity script
			if (entity != null)
			{
				script = asset_get_index("block_tile_entity_" + string_replace(string_lower(entity), "minecraft:", ""))
				if (script > -1)
				{
					build_pos_x = pos[|X]
					build_pos_y = pos[|Z]
					build_pos_z = pos[|Y]
					build_pos = build_pos_z * build_size_xy + build_pos_y * build_size_x + build_pos_x;
					block_current = builder_get_block(build_pos_x, build_pos_y, build_pos_z)
					block_state_id_current = builder_get_state_id(build_pos_x, build_pos_y, build_pos_z)
					script_execute(script, blocknbt)
				}
			}
		}
	}
				
	debug_timer_stop("res_load_scenery, Parse blocks")
	return true
}

/// CppSeparate void builder_read_schematic_blocks(Scope<obj_builder>)
/// Read the blocks in a .schematic file and generate 3 buffers for block object ids, block states and waterlogged flags
/// On the C++ side 16x16x16 sections are generated with the schematic palettes (these sections are pre-generated when importing from a world)
function builder_read_schematic_blocks()
{
	debug_timer_start()
	builder_start()
	sch_timeline_amount = 0
	
	for (var b = 0; b < build_size_total; b++)
	{
		var block, blockid, stateid, waterlogged;
		block = null
		blockid = 0
		stateid = null
		waterlogged = false
							
		if (!builder_scenery_legacy)
		{
			// Read index
			var bindex;
			if (sch_blockdata_ints)
			{
				// Read big endian int
				var off = sch_blockdata_array + b * 4;
				var b1 = buffer_peek(buffer_current, off, buffer_u8);
				var b2 = buffer_peek(buffer_current, off + 1, buffer_u8);
				var b3 = buffer_peek(buffer_current, off + 2, buffer_u8);
				var b4 = buffer_peek(buffer_current, off + 3, buffer_u8);
				bindex = b1 * 16777216 + b2 * 65536 + b3 * 256 + b4
			}
			else
				bindex = buffer_peek(buffer_current, sch_blockdata_array + b, buffer_u8)
									
			if (bindex > 0)
			{
				block = sch_palette_blocks[bindex]
				stateid = sch_palette_stateids[bindex]
				waterlogged = sch_palette_waterlogged[bindex]
			}
		}
		else
		{
			// Read legacy block ID & data
			var bid = buffer_peek(buffer_current, sch_legacy_blocksarray + b, buffer_u8)
			if (bid > 0 && legacy_block_set[bid])
			{
				var bdata = buffer_peek(buffer_current, sch_legacy_dataarray + b, buffer_u8) mod 16;
				block = legacy_block_obj[bid, bdata]
				stateid = legacy_block_state_id[bid, bdata]
			}
		}
							
		if (block != null)
		{
			blockid = block.block_id
			if (block.timeline)
				sch_timeline_amount++
		}
							
		buffer_write(block_obj, buffer_u16, blockid)
		buffer_write(block_state_id, buffer_u16, stateid)
		buffer_write(block_waterlogged, buffer_u8, waterlogged)
	}
	
	debug_timer_stop("Parse blocks")
}

function builder_read_schematic_tile_entities()
{
	// Tile entities
	if (ds_list_valid(sch_tileentity_list))
	{
		builder_spawn_threads(1)
		with (thread_list[|0])
		{
			debug_timer_start()
			for (var i = 0; i < ds_list_size(other.sch_tileentity_list); i++)
			{
				var entity, eid, ex, ey, ez;
				entity = other.sch_tileentity_list[|i]
						
				if (!builder_scenery_legacy)
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
				
				if (is_string(eid))
				{
					var script = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""));
					if (script > -1)
					{
						build_pos_x = ex
						build_pos_y = ey
						build_pos_z = ez
						build_pos = build_pos_z * build_size_xy + build_pos_y * build_size_x + build_pos_x;
						block_current = builder_get_block(build_pos_x, build_pos_y, build_pos_z)
						block_state_id_current = builder_get_state_id(build_pos_x, build_pos_y, build_pos_z)
						script_execute(script, entity)
					}
				}
			}
			debug_timer_stop("Parse Tile Entities")
		}
		builder_combine_threads()
	}
}

/// CppSeparate void builder_read_blocks_file(Scope<obj_builder>)
/// Reads a legacy .blocks file
function builder_read_blocks_file()
{
	debug_timer_start()
	
	file_map = buffer_read_string_short_be()
	build_size_y = buffer_read_short_be() // Derp
	build_size_x = buffer_read_short_be()
	build_size_z = buffer_read_short_be()
	log("Size", string(build_size_x) + " x " + string(build_size_y) + " x " + string(build_size_z))
	
	builder_start()
	sch_timeline_amount = 0
	
	repeat (build_size_total)
	{
		var blockid, stateid, bid, bdata;
		blockid = 0
		stateid = null
							
		// Read legacy block ID & data
		bid = buffer_read(buffer_current, buffer_u8)
		bdata = buffer_read(buffer_current, buffer_u8) mod 16
		if (bid > 0)
		{
			var block = legacy_block_obj[bid, bdata];
			stateid = legacy_block_state_id[bid, bdata]
			if (block != null)
			{
				blockid = block.block_id
				if (block.timeline)
					sch_timeline_amount++
			}
		}
							
		buffer_write(block_obj, buffer_u16, blockid)
		buffer_write(block_state_id, buffer_u16, stateid)
	}
	
	debug_timer_stop("Loaded .blocks")
}