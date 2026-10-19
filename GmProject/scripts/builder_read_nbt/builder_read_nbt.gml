function builder_read_nbt(structuremap)
{
	scenery_structure = true
	
	if (!ds_map_valid(structuremap))
	{
		log("Structure error", "Not a structure file")
		return false
	}

	// Read dimensions in Minecraft axis order
	var sizemap = structuremap[?"size"];
	if (!ds_list_valid(sizemap) || ds_list_size(sizemap) != 3)
	{
		log("Structure error", "Invalid size list")
		return false
	}
	
	for (var a = X; a <= Z; a++)
	{
		var size = sizemap[|a];
		if (!is_real(size) || size <= 0 || size != floor(size))
		{
			log("Structure error", "Invalid structure size")
			return false
		}
	}
	
	mc_builder.build_size[X] = sizemap[|X]
	mc_builder.build_size[Y] = sizemap[|Z]
	mc_builder.build_size[Z] = sizemap[|Y]

	log("Size", [ mc_builder.build_size[X], mc_builder.build_size[Y], mc_builder.build_size[Z] ])

	// Pick the selected variant or the single palette
	var paletteslist, palettelist, palette, blocklist;
	paletteslist = structuremap[?"palettes"]
	
	scenery_palette_size = 0
	if (ds_list_valid(paletteslist) && ds_list_size(paletteslist) > 0)
	{
		scenery_palette_size = ds_list_size(paletteslist)
		palettelist = paletteslist[|scenery_palette mod scenery_palette_size]
	}
	else
		palettelist = structuremap[?"palette"]
	
	if (!ds_list_valid(palettelist) || ds_list_size(palettelist) = 0)
	{
		log("Structure error", "Palette not found")
		return false
	}

	palette = []
	for (var i = 0; i < ds_list_size(palettelist); i++)
		palette[i] = builder_read_block_state(palettelist[|i])

	// Validate sparse block positions and states before allocating the builder
	blocklist = structuremap[?"blocks"]
	if (!ds_list_valid(blocklist))
	{
		log("Structure error", "Block list not found")
		return false
	}
	
	for (var i = 0; i < ds_list_size(blocklist); i++)
	{
		var blockmap, pos, state;
		blockmap = blocklist[|i]
		if (!ds_map_valid(blockmap))
			return false
		
		pos = blockmap[?"pos"]
		state = blockmap[?"state"]
		
		if (!ds_list_valid(pos) || ds_list_size(pos) != 3 || 
			!is_real(state) || state < 0 || state >= array_length(palette) || state != floor(state))
		{
			log("Structure error", "Invalid block position or palette index")
			return false
		}
		
		for (var a = X; a <= Z; a++)
		{
			var coordinate = pos[|a];
			if (!is_real(coordinate) || coordinate < 0 || coordinate >= sizemap[|a] || coordinate != floor(coordinate))
			{
				log("Structure error", "Block position outside structure")
				return false
			}
		}
	}

	var integrityamount, res;
	integrityamount = scenery_integrity
	res = id
	
	with (mc_builder)
	{
		debug_timer_start()
		
		file_map = ""
		builder_scenery_legacy = false
		
		builder_start()
		builder_spawn_threads(1)
		
		with (thread_list[|0])
		{
			for (var i = 0; i < ds_list_size(blocklist); i++)
			{
				var blockmap, pos, state, blocknbt;
				blockmap = blocklist[|i]
				pos = blockmap[?"pos"]
				state = palette[blockmap[?"state"]]
				blocknbt = blockmap[?"nbt"]
				
				build_pos[X] = pos[|X]
				build_pos[Y] = pos[|Z]
				build_pos[Z] = pos[|Y]
				build_pos_index = build_pos[Z] * build_size_xy + build_pos[Y] * build_size[X] + build_pos[X]

				var randmax, integrity;
				randmax = 10000
				integrity = builder_irandom(randmax - 1) / randmax
				
				if (integrity >= integrityamount)
					continue

				// Jigsaw replacements can include state properties
				if (ds_map_valid(blocknbt))
				{
					var finalstate = blocknbt[?"final_state"];
					if (is_string(finalstate))
						state = builder_read_block_state(finalstate)
				}

				block_current = state[0]
				if (block_current = null)
					continue
				
				block_state_id_current = state[1]
				
				builder_set_block(build_pos[X], build_pos[Y], build_pos[Z], block_current.block_id, block_state_id_current, state[2])
			}

			with (res)
				res_load_scenery_block_map()

			for (var i = 0; i < ds_list_size(blocklist); i++)
			{
				var blockmap, pos, blocknbt, entity;
				blockmap = blocklist[|i]
				pos = blockmap[?"pos"]
				blocknbt = blockmap[?"nbt"]
				if (!ds_map_valid(blocknbt) || is_string(blocknbt[?"final_state"]))
					continue

				entity = blocknbt[?"id"]
				if (!is_string(entity))
					continue

				build_pos[X] = pos[|X]
				build_pos[Y] = pos[|Z]
				build_pos[Z] = pos[|Y]
				build_pos_index = build_pos[Z] * build_size_xy + build_pos[Y] * build_size[X] + build_pos[X]
				block_current = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z])
				if (block_current = null)
					continue

				block_state_id_current = builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z])
				var scr = asset_get_index("block_tile_entity_" + string_replace(string_lower(entity), "minecraft:", ""));
				if (scr > -1)
					script_execute(scr, blocknbt)
			}
		}
		
		builder_combine_threads()
	}
	
	debug_timer_stop("res_load_scenery, Parse blocks")
	
	return true
}
