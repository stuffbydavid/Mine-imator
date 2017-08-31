/// project_load_legacy_resource()

with (new(obj_resource))
{
	loaded = true
	
	sortlist_add(app.res_list, id)
	
	save_id = buffer_read_int()
	save_id_map[?save_id] = save_id
	
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
			
	// No support for old packs
	if (type = "pack")
	{
		save_id_map[?save_id] = "default"
		instance_destroy()
	}
}