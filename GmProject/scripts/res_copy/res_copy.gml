function res_copy(to)
{
	to.type = type
	to.filename = filename
	to.display_name = display_name
	
	to.minecraft_hash = minecraft_hash
	to.player_skin = player_skin
	
	to.item_sheet_size = array_copy_1d(item_sheet_size)
	
	to.world_regions_dir = world_regions_dir
	to.world_name = world_name
	to.world_box_start = world_box_start
	to.world_box_end = world_box_end
	
	to.scenery_tl_set = scenery_tl_set
	to.scenery_tl_all_types = scenery_tl_all_types
	to.scenery_tl_types = array_copy_1d(scenery_tl_types)
	
	if (object_index = obj_resource && to.object_index = obj_resource)
	{
		ds_map_copy(to.scenery_block_map, scenery_block_map)
		ds_map_copy(to.scenery_tl_types_count_map, scenery_tl_types_count_map)
		to.scenery_tl_types_count_ready = scenery_tl_types_count_ready
	}
	else
		to.scenery_tl_types_count_ready = false
	
	to.scenery_filter_enabled = scenery_filter_enabled
	to.scenery_filter_mode = scenery_filter_mode
	to.scenery_filter_array = array_copy_1d(scenery_filter_array)
	
	to.scenery_download_skins = scenery_download_skins
	
	to.scenery_structure = scenery_structure
	to.scenery_integrity = scenery_integrity
	to.scenery_palette = scenery_palette
	to.scenery_palette_size = scenery_palette_size
	to.scenery_randomize = scenery_randomize
	
	to.material_format = material_format
	
	to.pack_has_materials = pack_has_materials
	to.pack_has_normals = pack_has_normals
}
