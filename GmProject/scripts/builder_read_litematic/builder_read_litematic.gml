/// @desc Read and flatten Litematic regions before mesh generation.

function builder_read_litematic(map, blocksonly = false)
{
	if (!ds_map_valid(map))
		return false

	var version, regionmap;
	version = map[?"Version"]
	regionmap = map[?"Regions"]
	
	if (!is_real(version) || version < 1 || version > 7 || version != floor(version) || !ds_map_valid(regionmap))
	{
		log("Litematic error", "Invalid regions or unsupported version")
		return false
	}

	var regions, offsets, sizes, bitcounts, keys, minimum, maximum, key;
	regions = []
	offsets = []
	sizes = []
	bitcounts = []
	keys = [ "x", "z", "y" ]
	minimum = vec3(0)
	maximum = vec3(0)
	key = ds_map_find_first(regionmap)

	// Validate regions and find the enclosing box in Mine-imator axis order
	while (!is_undefined(key))
	{
		if (regionmap[?key + "_NBT_type"] = e_nbt.TAG_COMPOUND)
		{
			var region, position, sizemap, start, size, palette, bits, volume, offset, length, r;
			region = regionmap[?key]
			if (!ds_map_valid(region))
				return false

			position = region[?"Position"]
			sizemap = region[?"Size"]
			palette = region[?"BlockStatePalette"]
			if (!ds_map_valid(position) || !ds_map_valid(sizemap) || !ds_list_valid(palette) || ds_list_size(palette) = 0)
			{
				log("Litematic error", "Missing region position, size or palette")
				return false
			}

			start = vec3(0)
			size = vec3(0)
			r = array_length(regions)

			for (var a = X; a <= Z; a++)
			{
				var coordinate, extent;
				coordinate = position[?keys[a]]
				extent = sizemap[?keys[a]]
				
				// NBT ints are signed, but the shared buffer reader returns unsigned values
				if (is_real(coordinate) && coordinate >= power(2, 31))
					coordinate -= power(2, 32)
				
				if (is_real(extent) && extent >= power(2, 31))
					extent -= power(2, 32)
				
				if (!is_real(coordinate) || !is_real(extent) || coordinate != floor(coordinate) || extent != floor(extent) || extent = 0 || abs(extent) > 65535)
				{
					log("Litematic error", "Invalid region dimensions")
					return false
				}

				// Negative sizes include the starting block, without mirroring the stored blocks
				start[a] = coordinate + min(0, extent + 1)
				size[a] = abs(extent)

				if (r = 0)
				{
					minimum[a] = start[a]
					maximum[a] = start[a] + size[a]
				}
				else
				{
					minimum[a] = min(minimum[a], start[a])
					maximum[a] = max(maximum[a], start[a] + size[a])
				}
			}

			bits = 2

			while (power(2, bits) < ds_list_size(palette))
				bits++

			volume = size[X] * size[Y] * size[Z]

			offset = region[?"BlockStates"]
			length = region[?"BlockStates_NBT_length"]
			if (region[?"BlockStates_NBT_type"] != e_nbt.TAG_LONG_ARRAY || !is_real(offset) || !is_real(length) ||
				offset < 0 || length != ceil(volume * bits / 64) || offset + length * 8 > buffer_get_size(buffer_current))
			{
				log("Litematic error", "Invalid packed block data")
				return false
			}

			regions[r] = region
			offsets[r] = start
			sizes[r] = size
			bitcounts[r] = bits
		}

		key = ds_map_find_next(regionmap, key)
	}

	if (array_length(regions) = 0)
	{
		log("Litematic error", "No regions found")
		return false
	}

	var totalsize = vec3(0);
	for (var a = X; a <= Z; a++)
	{
		totalsize[a] = maximum[a] - minimum[a]
		if (totalsize[a] > 65535)
		{
			log("Litematic error", "Enclosing size exceeds builder limits")
			return false
		}
	}

	// GM block buffers use two bytes per block and signed buffer offsets
	if (totalsize[X] * totalsize[Y] * totalsize[Z] >= power(2, 30))
	{
		log("Litematic error", "Enclosing volume exceeds builder limits")
		return false
	}

	scenery_structure = false
	scenery_palette_size = 0
	mc_builder.build_size = totalsize

	var valid, res;
	valid = true
	res = id

	with (mc_builder)
	{
		file_map = ""
		builder_scenery_legacy = false

		builder_start()
		builder_spawn_threads(1)

		with (thread_list[|0])
		{
			// Later regions overwrite earlier regions, including air
			for (var r = 0; r < array_length(regions) && valid; r++)
			{
				var region, start, size, palettelist, palette, offset, bits, volume;
				region = regions[r]
				start = offsets[r]
				size = sizes[r]
				palettelist = region[?"BlockStatePalette"]
				palette = []

				for (var i = 0; i < ds_list_size(palettelist); i++)
					palette[i] = builder_read_block_state(palettelist[|i])

				offset = region[?"BlockStates"]
				bits = bitcounts[r]

				volume = size[X] * size[Y] * size[Z]

				for (var p = 0; p < volume; p++)
				{
					var index, state;
					index = builder_read_litematic_index(offset, bits, p)
					if (index >= array_length(palette))
					{
						log("Litematic error", "Block data references a missing palette entry")
						valid = false
						break
					}

					state = palette[index]
					build_pos[X] = start[X] - minimum[X] + p mod size[X]
					build_pos[Y] = start[Y] - minimum[Y] + (p div size[X]) mod size[Y]
					build_pos[Z] = start[Z] - minimum[Z] + p div (size[X] * size[Y])

					block_current = state[0]
					if (block_current = null)
						builder_set_block(build_pos[X], build_pos[Y], build_pos[Z], 0, 0, false)
					else
					{
						builder_set_block(build_pos[X], build_pos[Y], build_pos[Z], block_current.block_id, state[1], state[2])
					}
				}
			}

			if (valid)
				with (res)
					valid = res_load_scenery_block_map(blocksonly)

			// Apply tile entities only after all regions have been flattened
			for (var r = 0; r < array_length(regions) && valid && !blocksonly; r++)
			{
				var region, start, size, entities;
				region = regions[r]
				start = offsets[r]
				size = sizes[r]
				entities = region[?"TileEntities"]
				
				if (!ds_list_valid(entities))
					continue

				for (var i = 0; i < ds_list_size(entities); i++)
				{
					var entity, data, pos, inside, covered, eid, scr;
					entity = entities[|i]
					
					if (!ds_map_valid(entity))
						continue

					pos = vec3(0)
					inside = true

					for (var a = X; a <= Z; a++)
					{
						var coordinate = entity[?keys[a]];
						if (!is_real(coordinate) || coordinate != floor(coordinate) || coordinate < 0 || coordinate >= size[a])
							inside = false
						else
							pos[a] = start[a] + coordinate
					}

					if (!inside)
						continue

					// Do not apply an earlier region's tile data to an overlapping replacement
					covered = false

					for (var n = r + 1; n < array_length(regions); n++)
					{
						var nextstart, nextsize;
						nextstart = offsets[n]
						nextsize = sizes[n]
						if (pos[X] >= nextstart[X] && pos[X] < nextstart[X] + nextsize[X] &&
							pos[Y] >= nextstart[Y] && pos[Y] < nextstart[Y] + nextsize[Y] &&
							pos[Z] >= nextstart[Z] && pos[Z] < nextstart[Z] + nextsize[Z])
						{
							covered = true
							break
						}
					}

					if (covered)
						continue

					data = entity
					if (version = 1)
						data = entity[?"TileNBT"]

					if (!ds_map_valid(data))
						continue

					eid = data[?"id"]
					if (!is_string(eid))
						continue

					scr = asset_get_index("block_tile_entity_" + string_replace(string_lower(eid), "minecraft:", ""))
					if (scr < 0)
						continue

					for (var a = X; a <= Z; a++)
						build_pos[a] = pos[a] - minimum[a]

					build_pos_index = build_pos[Z] * build_size_xy + build_pos[Y] * build_size[X] + build_pos[X]

					block_current = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z])
					if (block_current = null)
						continue

					block_state_id_current = builder_get_state_id(build_pos[X], build_pos[Y], build_pos[Z])
					script_execute(scr, data)
				}
			}
		}

		builder_combine_threads()

		if (valid && !blocksonly)
		{
			for (var r = 0; r < array_length(regions); r++)
			{
				var start = offsets[r];
				builder_read_entities(regions[r][?"Entities"], vec3(
					start[X] - minimum[X], start[Z] - minimum[Z], start[Y] - minimum[Y]
				))
			}
		}

		if (!valid)
			builder_done()
	}

	return valid
}
