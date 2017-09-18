/// minecraft_assets_load(version)
/// @arg version
/// @desc Loads assets from an archive.

// TODO: error check

var version, fname, zipfname;
version = argument0
fname = minecraft_directory + version + ".midata"
zipfname = minecraft_directory + version + ".zip"

if (!file_exists_lib(fname))
{
	log("Could not find Minecraft assets file", fname)
	return false
}

if (!file_exists_lib(zipfname))
{
	log("Could not find Minecraft assets archive", zipfname)
	return false
}

log("Loading version", version)

var typemap, map;
typemap = ds_map_create()
map = json_load(fname, typemap)
if (!ds_map_valid(map))
{
	log("Could not parse JSON", fname)
	ds_map_destroy(typemap)
	return false
}

var format = map[?"format"];
if (!is_real(format))
	format = e_minecraft_assets.FORMAT_110

if (format > minecraft_assets_format)
{
	error("Too new") // TODO
	return false
}

// Unzip archive
if (!dev_mode || dev_mode_unzip_assets)
	unzip(zipfname)

mc_block_state_file_map = ds_map_create() // filename -> states
mc_block_model_file_map = ds_map_create() // filename -> model

var err = true;

with (mc_assets)
{
	name = map[?"version"];
	
	// Model textures
	var modeltextureslist = map[?"model_textures"];
	if (is_undefined(modeltextureslist))
	{
		log("No model textures found")
		break
	}
	
	ds_list_copy(model_texture_list, modeltextureslist)
	
	// Block textures
	var blocktextureslist = map[?"block_textures"];
	if (is_undefined(blocktextureslist))
	{
		log("No block textures found")
		break
	}
	
	ds_list_copy(block_texture_list, blocktextureslist)
	
	// Animated block textures
	var blocktexturesanimatedlist = map[?"block_textures_animated"];
	if (is_undefined(blocktexturesanimatedlist))
	{
		log("No animated block textures found")
		break
	}
	
	ds_list_copy(block_texture_ani_list, blocktexturesanimatedlist)
	
	// Block texture colors
	var blocktexturescolorlist = map[?"block_textures_color"];
	if (is_undefined(blocktexturescolorlist))
	{
		log("No block texture colors found")
		break
	}
	
	ds_map_copy(block_texture_color_map, blocktexturescolorlist)
	
	// Convert from hex
	var key = ds_map_find_first(block_texture_color_map);
	while (!is_undefined(key))
	{
		if (string_char_at(block_texture_color_map[?key], 1) = "#")
			block_texture_color_map[?key] = hex_to_color(block_texture_color_map[?key])
		key = ds_map_find_next(block_texture_color_map, key)
	}
	
	// Item textures
	var itemtextureslist = map[?"item_textures"];
	if (is_undefined(itemtextureslist))
	{
		log("No item textures found")
		break
	}
	
	ds_list_copy(item_texture_list, itemtextureslist)
	
	// Create sheets and texture depth
	with (res_def)
	{
		res_load_pack_model_textures()
		res_load_pack_block_textures()
		res_load_pack_item_textures()
		res_load_pack_misc()
	}
	
	// Characters
	var characterslist = map[?"characters"];
	if (is_undefined(characterslist))
	{
		log("No character list found")
		break
	}
	
	for (var i = 0; i < ds_list_size(characterslist); i++)
	{
		var model = model_load(characterslist[|i], character_directory);
		if (!model) // Something went wrong!
		{
			log("Could not load model")
			continue
		}
		
		model_name_map[?model.name] = model
		
		ds_list_add(char_list, model)
	}
	
	// Special blocks
	var specialblockslist = map[?"special_blocks"];
	if (is_undefined(specialblockslist))
	{
		log("No special block list found")
		break
	}
	
	for (var i = 0; i < ds_list_size(specialblockslist); i++)
	{
		var model = model_load(specialblockslist[|i], special_block_directory);
		if (!model) // Something went wrong!
		{
			log("Could not load model")
			continue
		}
		
		model_name_map[?model.name] = model
		
		ds_list_add(special_block_list, model)
	}
	
	// Blocks
	var blockslist = map[?"blocks"];
	if (is_undefined(blockslist))
	{
		log("No block list found")
		break
	}
	
	debug_timer_start()
	for (var i = 0; i < ds_list_size(blockslist); i++)
	{
		var blockmap, block;
		blockmap = blockslist[|i]
		block = block_load(blockmap, typemap)
		if (!block)
		{
			log("Could not load block")
			continue
		}
		
		// Save name in map
		block_name_map[?block.name] = block
			
		// Save legacy ID in map if available
		if (is_real(blockmap[?"legacy_id"]))
			block_legacy_id_map[?blockmap[?"legacy_id"]] = block
			
		ds_list_add(block_list, block)
	}
	
	// Flowing Water/Lava
	block_name_map[?"flowing_water"] = block_name_map[?"water"]
	block_name_map[?"flowing_lava"] = block_name_map[?"lava"]
	block_legacy_id_map[?8] = block_legacy_id_map[?9]
	block_legacy_id_map[?10] = block_legacy_id_map[?11]
	
	debug_timer_stop("Load blocks")
	
	// Clear up loaded models
	key = ds_map_find_first(mc_block_model_file_map)
	while (!is_undefined(key))
	{
		with (mc_block_model_file_map[?key])
			instance_destroy()
		key = ds_map_find_next(mc_block_model_file_map, key)
	}
		
	err = false
}

ds_map_destroy(mc_block_state_file_map)
ds_map_destroy(mc_block_model_file_map)
ds_map_destroy(map)
ds_map_destroy(typemap)

if (!err)
	log("Loaded successfully")

return !err