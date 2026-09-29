function builder_read_schematic_nbt(structuremap)
{
	scenery_structure = true
				
	// Check DataVersion tag
	var structureversion = 1;
				
	if (!is_undefined(structuremap[?"DataVersion"]))
		structureversion = structuremap[?"DataVersion"]
				
	if (structureversion < 2000)
	{
		log("Structure error", "Unsupported format, version too low")
		return false
	}
				
	// Get size
	var sizemap = structuremap[?"size"];
	mc_builder.build_size_x = sizemap[|X]
	mc_builder.build_size_y = sizemap[|Z]
	mc_builder.build_size_z = sizemap[|Y]
	log("Size", [ mc_builder.build_size_x, mc_builder.build_size_y, mc_builder.build_size_z ])
				
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
			var vars = [];
						
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
	var blocklist = structuremap[?"blocks"];
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
			blocknbt = blockmap[?"nbt"]
			if (!is_undefined(blocknbt))
			{
				var finalstate = blocknbt[?"final_state"];
							
				if (!is_undefined(finalstate))
				{
					// Replace jigsaw with final_state value
					block = mc_assets.block_id_map[?finalstate]
								
					if (is_undefined(block))
						continue
								
					var vars = [];
								
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
				var script = asset_get_index("block_tile_entity_" + string_replace(string_lower(entity), "minecraft:", ""));
				if (script > -1)
				{
					build_pos_x = pos[|X]
					build_pos_y = pos[|Z]
					build_pos_z = pos[|Y]
					build_pos = build_pos_z * build_size_xy + build_pos_y * build_size_x + build_pos_x
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
