/// project_load_legacy_value_types()

function project_load_legacy_value_types()
{
	value_type[e_value_type.TRANSFORM_POS] = buffer_read_byte()
	value_type[e_value_type.TRANSFORM_ROT] = buffer_read_byte()
	value_type[e_value_type.TRANSFORM_SCA] = buffer_read_byte()
	value_type[e_value_type.TRANSFORM_BEND] = buffer_read_byte()
	value_type[e_value_type.MATERIAL_COLOR] = buffer_read_byte()
	value_type[e_value_type.PARTICLES] = buffer_read_byte()
	value_type[e_value_type.LIGHT] = buffer_read_byte()
	value_type[e_value_type.SPOTLIGHT] = buffer_read_byte()
	value_type[e_value_type.CAMERA] = buffer_read_byte()
	
	if (load_format < e_project.FORMAT_100_DEBUG)
		value_type[e_value_type.MATERIAL_TEXTURE] = buffer_read_byte() 
	
	if (load_format >= e_project.FORMAT_100_DEMO_4)
		value_type[e_value_type.BACKGROUND] = buffer_read_byte()
	else
		value_type[e_value_type.BACKGROUND] = false
	
	if (load_format >= e_project.FORMAT_100_DEBUG)
		value_type[e_value_type.MATERIAL_TEXTURE] = buffer_read_byte() 
	
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
	
	if (load_format >= e_project.FORMAT_100_DEMO_4)
	{
		value_type[e_value_type.HIERARCHY] = buffer_read_byte()
		value_type[e_value_type.GRAPHICS] = buffer_read_byte()
	}
	
	if (load_format < e_project.FORMAT_100_DEBUG) // Bug in demos
	{
		value_type[e_value_type.HIERARCHY] = true
		value_type[e_value_type.GRAPHICS] = true
	}
	
	if (load_format >= e_project.FORMAT_100_DEBUG)
		value_type[e_value_type.AUDIO] = buffer_read_byte()
	else
		value_type[e_value_type.AUDIO] = false
}
