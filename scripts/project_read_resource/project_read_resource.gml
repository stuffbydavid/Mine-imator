/// project_read_resource()

debug("Resource object") debug_indent++

sortlist_add(app.res_list, id)

loaded = true
iid = iid_read()								debug("iid", iid)
iid_current = max(iid + 1, iid_current)
type = buffer_read_string_int()
if (type = "scenery")
	type = "schematic"
	
if (type = "item")
	type = "itemsheet"
	
if (type = "block")
	type = "blocksheet"
	
if (type = "particles")
	type = "particlesheet"
debug("type", type)

filename = buffer_read_string_int()				debug("filename", filename)
filename_out = filename
is_skin = buffer_read_byte()					debug("is_skin", is_skin)
pack_description = buffer_read_string_int()		debug("pack_description", pack_description)
if (load_format >= project_100debug)
	block_frames = buffer_read_byte()
else
	block_frames = 32

debug("block_frames", block_frames)
if (type = "pack" || type = "blocksheet")
{
	if (load_format >= project_100demo4)
	{
		for (var b = 0; b < 32 * 16; b++)
			block_ani[b] = buffer_read_byte()
	}
	else
		block_ani[32 * 16] = false
}

res_load()
debug_indent--
