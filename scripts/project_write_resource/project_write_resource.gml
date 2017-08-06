/// project_write_resource()

buffer_write_int(iid)
buffer_write_string_int(type)
buffer_write_string_int(filename)
buffer_write_byte(is_skin)
buffer_write_string_int(pack_description)
//buffer_write_byte(block_frames)

if (type = "pack" || type = "blocksheet")
	for (var b = 0; b < 512; b++)
		buffer_write_byte(block_ani[b])

if (load_folder != save_folder)
	res_export()
