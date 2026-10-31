/// @desc Imports scenery from a valid file of blocks.
/// @arg filename
/// @arg [blocksonly]

function res_load_scenery_file(fn, blocksonly = false)
{
	var ext, rootmap, schmap, valid;
	ext = filename_ext(fn)
	valid = true

	if (!file_exists_lib(fn))
		return false

	mc_builder.sch_entities = []

	log("Loading " + ext, fn)

	debug_timer_start()

	if (ext = ".blocks")
	{
		buffer_current = buffer_load_lib(fn)
		with (mc_builder)
		{
			builder_scenery_legacy = true
			builder_read_blocks_file()
		}

		buffer_delete(buffer_current)

		scenery_structure = false
		scenery_palette_size = 0
		
		valid = res_load_scenery_block_map(blocksonly)

		if (blocksonly || !valid)
			with (mc_builder)
				builder_done()

		return valid
	}

	// GZunzip
	file_delete_lib(temp_file)
	gzunzip(fn, temp_file)

	if (!file_exists_lib(temp_file))
	{
		log("GZunzip error", "gzunzip")
		return false
	}

	buffer_current = buffer_load(temp_file)

	// Read NBT structure
	rootmap = nbt_read_tag_compound();

	if (rootmap = null)
	{
		buffer_delete(buffer_current)
		return false
	}

	debug_timer_stop("res_load_scenery_file, Parse NBT")

	if (debug_schematics)
		nbt_debug_tag_compound("root", rootmap)

	// Accept named, nested and unnamed schematic roots
	schmap = rootmap[?"Schematic"];
	if (!ds_map_valid(schmap))
	{
		schmap = rootmap[?""]
		if (ds_map_valid(schmap) && ds_map_valid(schmap[?"Schematic"]))
			schmap = schmap[?"Schematic"]
	}

	// Read Litematic file
	if (ds_map_valid(schmap) && ds_map_valid(schmap[?"Regions"]))
		valid = builder_read_litematic(schmap, blocksonly)

	// Structure palettes use lowercase lists rather than Sponge compounds
	else if (ds_map_valid(schmap) && ds_list_valid(schmap[?"size"]))
		valid = builder_read_nbt(schmap, blocksonly)

	else
	{
		scenery_structure = false
		scenery_palette_size = 0

		with (mc_builder)
		{
			valid = builder_read_schematic(schmap)
			if (!valid)
				break

			builder_read_schematic_blocks()

			with (other.id)
				valid = res_load_scenery_block_map(blocksonly)

			if (valid && !blocksonly)
				builder_read_schematic_tile_entities()
		}
	}

	// NBT array tags hold offsets into this buffer until decoding is complete
	buffer_delete(buffer_current)
	ds_map_destroy(rootmap)

	if (blocksonly || !valid)
		with (mc_builder)
			builder_done()

	return valid
}
