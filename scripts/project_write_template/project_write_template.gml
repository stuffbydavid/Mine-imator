/// project_write_template()

buffer_write_int(iid)
buffer_write_string_int(type)
buffer_write_string_int(name)

buffer_write_int(iid_get(char_skin))
if (char_skin)
	char_skin.save = true
if (char_model)
	buffer_write_string_int(char_model.name)
else
	buffer_write_string_int("")
buffer_write_int(char_bodypart)

buffer_write_int(iid_get(item_tex))
if (item_tex)
	item_tex.save = true
buffer_write_byte(item_sheet)
buffer_write_int(item_n)
buffer_write_byte(item_3d)
buffer_write_byte(item_face_camera)
buffer_write_byte(item_bounce)

buffer_write_short(block_id)
buffer_write_byte(block_data)
buffer_write_int(iid_get(block_tex))
if (block_tex)
	block_tex.save = true

if (scenery)
{
	buffer_write_int(iid_get(scenery))
	scenery.save = true
}
else
	buffer_write_int(0)

buffer_write_byte(repeat_toggle)
buffer_write_int(repeat_x)
buffer_write_int(repeat_y)
buffer_write_int(repeat_z)

buffer_write_int(iid_get(shape_tex))
if (shape_tex)
	shape_tex.save = true
	
buffer_write_byte(shape_tex_mapped)
buffer_write_double(shape_tex_hoffset)
buffer_write_double(shape_tex_voffset)
buffer_write_double(shape_tex_hrepeat)
buffer_write_double(shape_tex_vrepeat)
buffer_write_byte(shape_tex_hmirror)
buffer_write_byte(shape_tex_vmirror)
buffer_write_byte(shape_closed)
buffer_write_byte(shape_invert)
buffer_write_int(shape_detail)
buffer_write_byte(shape_face_camera)

buffer_write_int(iid_get(text_font))
if (text_font)
	text_font.save = true
buffer_write_byte(text_face_camera)

if (type = "particles")
	project_write_particles()
