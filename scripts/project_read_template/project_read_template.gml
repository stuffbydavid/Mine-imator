/// project_read_template()

debug("Template") debug_indent++

if (temp_creator = app)
	sortlist_add(app.lib_list, id)

loaded = true
iid = iid_read()								  debug("iid", iid)
iid_current = max(iid + 1, iid_current)
type = buffer_read_string_int()				   debug("type", type)
name = buffer_read_string_int()				   debug("name", name)
if (load_format = project_100demo2) // count
	buffer_read_int()

char_skin = iid_read()							debug("char_skin", char_skin)
if (load_format >= project_100debug)
	char_model = buffer_read_string_int()
else
	char_model = project_read_old_char_model(buffer_read_int())

//char_model = char_find(char_model)				debug("char_model", char_model) // TODO
char_bodypart = buffer_read_int()				 debug("char_bodypart", char_bodypart)

item_tex = iid_read()							 debug("item_tex", item_tex)
if (load_format >= project_100debug)
	item_sheet = buffer_read_byte()			   debug("item_sheet", item_sheet)
item_n = buffer_read_int()						debug("item_n", item_n)
item_3d = buffer_read_byte()					  debug("item_3d", item_3d)
item_face_camera = buffer_read_byte()			 debug("item_face_camera", item_face_camera)
item_bounce = buffer_read_byte()				  debug("item_bounce", item_bounce)

block_id = buffer_read_short()					debug("block_id", block_id)
block_data = buffer_read_byte()				   debug("block_data", block_data)
block_tex = iid_read()							debug("block_tex", block_tex)

scenery = iid_read()							  debug("scenery", scenery)

repeat_toggle = buffer_read_byte()				debug("repeat_toggle", repeat_toggle)
repeat_x = buffer_read_int()					  debug("repeat_x", repeat_x)
repeat_y = buffer_read_int()					  debug("repeat_y", repeat_y)
repeat_z = buffer_read_int()					  debug("repeat_z", repeat_z)

shape_tex = iid_read()							debug("shape_tex", shape_tex)
if (load_format >= project_100debug)
{
	shape_tex_mapped = buffer_read_byte()		 debug("shape_tex_mapped", shape_tex_mapped)
	shape_tex_hoffset = buffer_read_double()	  debug("shape_tex_hoffset", shape_tex_hoffset)
	shape_tex_voffset = buffer_read_double()	  debug("shape_tex_voffset", shape_tex_voffset)
}
shape_tex_hrepeat = buffer_read_double()		  debug("shape_tex_hrepeat", shape_tex_hrepeat)
shape_tex_vrepeat = buffer_read_double()		  debug("shape_tex_vrepeat", shape_tex_vrepeat)
shape_tex_hmirror = buffer_read_byte()			debug("shape_tex_hmirror", shape_tex_hmirror)
shape_tex_vmirror = buffer_read_byte()			debug("shape_tex_vmirror", shape_tex_vmirror)
if (load_format >= project_100debug)
	shape_closed = buffer_read_byte()			 debug("shape_closed", shape_closed)
shape_invert = buffer_read_byte()				 debug("shape_invert", shape_invert)
shape_detail = buffer_read_int()				  debug("shape_detail", shape_detail)
if (load_format >= project_100debug)
	shape_face_camera = buffer_read_byte()		debug("shape_face_camera", shape_face_camera)

text_font = iid_read()							debug("text_font", text_font)
if (load_format < project_100demo4)
{
	buffer_read_string_int() // system font name
	buffer_read_byte() // system font bold
	buffer_read_byte() // system font italic
}
text_face_camera = buffer_read_byte()			 debug("text_face_camera", text_face_camera)

if (type = "particles")
	project_read_particles()
debug_indent--
