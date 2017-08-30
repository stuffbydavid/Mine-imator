/// project_load_legacy_value_types()

value_type[e_value_type.POSITION] = buffer_read_byte()
value_type[e_value_type.ROTATION] = buffer_read_byte()
value_type[e_value_type.SCALE] = buffer_read_byte()
value_type[e_value_type.BEND] = buffer_read_byte()
value_type[e_value_type.COLOR] = buffer_read_byte()
value_type[e_value_type.PARTICLES] = buffer_read_byte()
value_type[e_value_type.LIGHT] = buffer_read_byte()
value_type[e_value_type.SPOTLIGHT] = buffer_read_byte()
value_type[e_value_type.CAMERA] = buffer_read_byte()

if (load_format < e_project.FORMAT_100_DEBUG)
	value_type[e_value_type.TEXTURE] = buffer_read_byte() 

if (load_format >= e_project.FORMAT_100_DEMO_4)
	value_type[e_value_type.BACKGROUND] = buffer_read_byte()
else
	value_type[e_value_type.BACKGROUND] = false

if (load_format >= e_project.FORMAT_100_DEBUG)
	value_type[e_value_type.TEXTURE] = buffer_read_byte() 

if (load_format >= e_project.FORMAT_100_DEBUG)
{
	value_type[e_value_type.SOUND] = buffer_read_byte()
	value_type[e_value_type.KEYFRAME] = buffer_read_byte()
}
else
{
	value_type[e_value_type.SOUND] = false
	value_type[e_value_type.KEYFRAME] = true
}

value_type[e_value_type.ROT_POINT] = buffer_read_byte()

if (load_format >= e_project.FORMAT_100_DEMO_4) {
	value_type[e_value_type.HIERARCHY] = buffer_read_byte()
	value_type[e_value_type.GRAPHICS] = buffer_read_byte()
}

if (load_format < e_project.FORMAT_100_DEBUG) // Bug in demos
	value_type[e_value_type.HIERARCHY] = true
	value_type[e_value_type.GRAPHICS] = true

if (load_format >= e_project.FORMAT_100_DEBUG)
	value_type[e_value_type.AUDIO] = buffer_read_byte()
else
	value_type[e_value_type.AUDIO] = false
