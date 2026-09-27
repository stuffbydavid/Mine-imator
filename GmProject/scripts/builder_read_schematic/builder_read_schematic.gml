// Read a .schematic file, returns whether successful

function builder_read_schematic(map)
{
	if (!ds_map_valid(map))
	{
		log("Schematic error", "Not a schematic file")
		return false
	}
	
	// Get format, version 3 keeps the palette inside a Blocks compound while a legacy
	// schematic stores a Blocks byte array, so compare the tag type instead of the value
	builder_scenery_legacy = is_undefined(map[?"Palette"]) && (map[?"Blocks_NBT_type"] != e_nbt.TAG_COMPOUND)
	
	var blocksmap = map;
	
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
		if (version > 3)
		{
			log("Schematic error", "Unsupported format, version too high")
			return false
		}
		
		// Version 3 moved the palette, block data and block entities into a Blocks compound
		if (version >= 3)
		{
			blocksmap = map[?"Blocks"]
			if (!ds_map_valid(blocksmap))
			{
				log("Schematic error", "Blocks compound not found")
				return false
			}
		}
		
		// Get palette
		var palettemap = blocksmap[?"Palette"]
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
		
		var palettemax = 0;
		var key = ds_map_find_first(palettemap);
		while (!is_undefined(key))
		{
			if (!string_contains(key, "_NBT_"))
			{
				var index, bracketindex;
				index = palettemap[?key]
				bracketindex = string_pos("[", key)
				
				if (index + 1 > palettemax)
					palettemax = index + 1
					
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
		
		// Get block array, version 3 renamed BlockData to Blocks.Data
		var blockdatakey = (version >= 3 ? "Data" : "BlockData");
		sch_blockdata_array = blocksmap[?blockdatakey]
		if (is_undefined(sch_blockdata_array))
		{
			log("Schematic error", "Block data array not found")
			return false
		}
		
		sch_blockdata_ints = (blocksmap[?blockdatakey + "_NBT_type"] = e_nbt.TAG_INT_ARRAY)
		debug("blockdataints", sch_blockdata_ints)
		
		// BlockData is an array of varints (Sponge Schematic specification). An index below 128
		// encodes as a single byte and can be read from the file buffer directly, anything above
		// spans several bytes. The block loop needs random access into the array, so decode the
		// indices once into big endian integers appended to the file buffer.
		if (!sch_blockdata_ints && palettemax > 128)
		{
			var blockamount, basepos, readpos, endpos, writepos;
			blockamount = build_size_x * build_size_y * build_size_z
			basepos = buffer_get_size(buffer_current)
			readpos = sch_blockdata_array
			endpos = sch_blockdata_array + blocksmap[?blockdatakey + "_NBT_length"]
			writepos = basepos
			
			// Missing entries are left at zero, so a truncated array still loads
			buffer_resize(buffer_current, basepos + blockamount * 4)
			
			for (var i = 0; i < blockamount; i++)
			{
				var value, mul, byte;
				value = 0
				mul = 1
				byte = 128
				
				while (byte >= 128)
				{
					if (readpos >= endpos)
					{
						log("Schematic warning", "BlockData ends before the last block")
						break
					}
					
					byte = buffer_peek(buffer_current, readpos, buffer_u8)
					readpos++
					value += (byte mod 128) * mul
					mul *= 128
				}
				
				if (readpos >= endpos && byte >= 128)
					break
				
				// Store as a big endian integer, matching the TAG_Int_Array layout
				buffer_poke(buffer_current, writepos, buffer_u8, (value div 16777216) mod 256)
				buffer_poke(buffer_current, writepos + 1, buffer_u8, (value div 65536) mod 256)
				buffer_poke(buffer_current, writepos + 2, buffer_u8, (value div 256) mod 256)
				buffer_poke(buffer_current, writepos + 3, buffer_u8, value mod 256)
				writepos += 4
			}
			
			log("Decoded varint BlockData", blockamount)
			sch_blockdata_array = basepos
			sch_blockdata_ints = true
		}
		
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
		
	// Version 2 renamed TileEntities to BlockEntities, version 3 moved it into Blocks
	sch_tileentity_list = map[?"TileEntities"];
	if (!ds_list_valid(sch_tileentity_list))
		sch_tileentity_list = map[?"BlockEntities"]
	if (!ds_list_valid(sch_tileentity_list))
		sch_tileentity_list = blocksmap[?"BlockEntities"]
	
	return true
}
