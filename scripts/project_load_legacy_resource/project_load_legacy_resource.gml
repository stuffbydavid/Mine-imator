/// project_load_legacy_resource()

with (new(obj_resource))
{
	loaded = true
	load_id = buffer_read_int()
	save_id_map[?load_id] = load_id
	
	type = buffer_read_string_int()
	
	if (type = "scenery")
		type = "schematic"
		
	if (type = "item")
		type = "itemsheet"
		
	if (type = "block" || type = "blocksheet")
		type = "legacyblocksheet"
		
	if (type = "particles")
		type = "particlesheet"
		
	filename = buffer_read_string_int()
	
	player_skin = buffer_read_byte()
	/*pack_description = */buffer_read_string_int()
	
	if (load_format >= e_project.FORMAT_100_DEBUG)
		/*block_frames = */buffer_read_byte()
		
	if (load_format >= e_project.FORMAT_100_DEMO_4 && (type = "pack" || type = "legacyblocksheet"))
		repeat (32 * 16)
			buffer_read_byte() // block_ani
			
	// Define sheet size
	if (type = "itemsheet")
		item_sheet_size = vec2(16, 16)
			
	// No support for old unzipped packs, sorry!
	if (type = "pack")
	{
		save_id_map[?load_id] = "default"
		instance_destroy()
		break
	}
	
	sortlist_add(app.res_list, id)
}
