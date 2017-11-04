/// project_load_legacy_resource()

with (new(obj_resource))
{
	loaded = true
	load_id = buffer_read_int()
	save_id_map[?load_id] = load_id
	
	var typename = buffer_read_string_int()
	
	if (typename = "scenery")
		typename = "schematic"
		
	if (typename = "item")
		typename = "itemsheet"
		
	if (typename = "block" || typename = "blocksheet")
		typename = "legacyblocksheet"
		
	if (typename = "particles")
		typename = "particlesheet"
		
	type = ds_list_find_index(res_type_name_list, typename)
	
	filename = buffer_read_string_int()
	
	player_skin = buffer_read_byte()
	/*pack_description = */buffer_read_string_int()
	
	if (load_format >= e_project.FORMAT_100_DEBUG)
		/*block_frames = */buffer_read_byte()
		
	if (load_format >= e_project.FORMAT_100_DEMO_4 && (type = e_res_type.PACK || type = e_res_type.LEGACY_BLOCK_SHEET))
		repeat (32 * 16)
			buffer_read_byte() // block_ani
			
	// Define sheet size
	if (type = e_res_type.ITEM_SHEET)
		item_sheet_size = vec2(16, 16)
			
	// No support for old unzipped packs, sorry!
	if (type = e_res_type.PACK)
	{
		save_id_map[?load_id] = "default"
		instance_destroy()
		break
	}
	
	scenery_tl_add = false
	
	sortlist_add(app.res_list, id)
}
