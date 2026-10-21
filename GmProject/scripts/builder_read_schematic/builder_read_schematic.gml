/// @desc Read a .schematic file, returns whether successful.

function builder_read_schematic(map)
{
	if (!ds_map_valid(map))
	{
		log("Schematic error", "Not a schematic file")
		return false
	}
	
	// Get format
	builder_scenery_legacy = (is_undefined(map[?"Version"]) && is_undefined(map[?"Palette"]) && (map[?"Blocks_NBT_type"] != e_nbt.TAG_COMPOUND))
	
	sch_legacy_add_array = null
	file_map = ""
	
	var blocksmap, sizekeys;
	blocksmap = map
	sizekeys = [ "Width", "Length", "Height" ]
	
	// Get size
	for (var a = X; a <= Z; a++)
	{
		var size = map[?sizekeys[a]];
		if (!is_real(size))
		{
			log("Schematic error", "Size not fully defined")
			return false
		}
		
		if (size <= 0 || size != floor(size) || size > 65535)
		{
			log("Schematic error", "Size must be a valid integer")
			return false
		}
		
		build_size[a] = size
	}
	
	log("Size", string(build_size[X]) + " x " + string(build_size[Y]) + " x " + string(build_size[Z]))
	
	if (!builder_scenery_legacy)
	{
		// Check version
		var version = map[?"Version"];
		if (!is_real(version))
		{
			log("Schematic error", "Version not available")
			return false
		}
		
		log("Version", map[?"Version"])
		if (version < 1 || version > 3 || version != floor(version))
		{
			log("Schematic error", "Unsupported schematic version")
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
		var palettemap = blocksmap[?"Palette"];
		if (!ds_map_valid(palettemap))
		{
			log("Schematic error", "Palette not found")
			return false
		}
		
		// Remap sparse palette IDs to compact internal indices
		var paletteindices, key, valid;
		paletteindices = ds_int_map_create()
		
		sch_palette_blocks = []
		sch_palette_state_ids = []
		sch_palette_waterlogged = []
		
		key = ds_map_find_first(palettemap)
		valid = true
		
		while (!is_undefined(key))
		{
			if (!string_contains(key, "_NBT_"))
			{
				var index, slot, state;
				index = palettemap[?key]
				if (!is_real(index) || index < 0 || index != floor(index) || index > $7fffffff || ds_map_exists(paletteindices, index))
				{
					valid = false
					break
				}
				
				slot = array_length(sch_palette_blocks)
				paletteindices[?index] = slot
				state = builder_read_block_state(key)
				
				sch_palette_blocks[slot] = state[0]
				sch_palette_state_ids[slot] = state[1]
				sch_palette_waterlogged[slot] = state[2]
			}
			
			key = ds_map_find_next(palettemap, key)
		}
		
		if (valid && ds_map_size(paletteindices) > 0)
		{
			valid = builder_read_schematic_data(version, blocksmap, paletteindices, build_size[X] * build_size[Y] * build_size[Z])
		}
		else
		{
			log("Schematic error", "Invalid or empty palette")
			valid = false
		}
		
		ds_map_destroy(paletteindices)
		
		if (!valid)
			return false
		
		// Get map
		var metadata = map[?"Metadata"];
		if (ds_map_valid(metadata))
			file_map = metadata[?"FromMap"]
	}
	else
	{
		// Get block/data array
		sch_legacy_blocks_array = map[?"Blocks"]
		if (is_undefined(sch_legacy_blocks_array))
		{
			log("Schematic error", "Blocks array not found")
			return false
		}
		
		sch_legacy_data_array = map[?"Data"]
		if (is_undefined(sch_legacy_data_array))
		{
			log("Schematic error", "Data array not found")
			return false
		}
		
		// Legacy high block IDs must not alias unrelated vanilla blocks
		sch_legacy_add_array = map[?"AddBlocks"]
		if (is_undefined(sch_legacy_add_array))
			sch_legacy_add_array = null
		
		var blockamount, sourcesize;
		blockamount = build_size[X] * build_size[Y] * build_size[Z]
		sourcesize = buffer_get_size(buffer_current)
		
		if (map[?"Blocks_NBT_type"] != e_nbt.TAG_BYTE_ARRAY ||
			map[?"Data_NBT_type"] != e_nbt.TAG_BYTE_ARRAY ||
			map[?"Blocks_NBT_length"] != blockamount ||
			map[?"Data_NBT_length"] != blockamount ||
			sch_legacy_blocks_array + blockamount > sourcesize ||
			sch_legacy_data_array + blockamount > sourcesize)
		{
			log("Schematic error", "Invalid legacy block/data arrays")
			return false
		}
		
		if (sch_legacy_add_array != null)
		{
			if (map[?"AddBlocks_NBT_type"] != e_nbt.TAG_BYTE_ARRAY ||
				map[?"AddBlocks_NBT_length"] != ceil(blockamount / 2) ||
				sch_legacy_add_array + ceil(blockamount / 2) > sourcesize)
			{
				log("Schematic error", "Invalid legacy AddBlocks array")
				return false
			}
		}

		// Get map
		file_map = map[?"FromMap"]
	}
			
	if (is_undefined(file_map))
		file_map = ""
		
	// Version 2 renamed TileEntities to BlockEntities, version 3 moved it into Blocks
	sch_tileentity_list = map[?"TileEntities"]
	
	if (!ds_list_valid(sch_tileentity_list))
		sch_tileentity_list = map[?"BlockEntities"]
	
	if (!ds_list_valid(sch_tileentity_list))
		sch_tileentity_list = blocksmap[?"BlockEntities"]

	builder_read_entities(map[?"Entities"])
	
	return true
}
