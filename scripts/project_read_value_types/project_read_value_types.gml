/// project_read_value_types()

value_type[POSITION] = buffer_read_byte()		 debug("value_type[POSITION]", value_type[POSITION])
value_type[ROTATION] = buffer_read_byte()		 debug("value_type[ROTATION]", value_type[ROTATION])
value_type[SCALE] = buffer_read_byte()			debug("value_type[SCALE]", value_type[SCALE])
value_type[BEND] = buffer_read_byte()			 debug("value_type[BEND]", value_type[BEND])
value_type[COLOR] = buffer_read_byte()			debug("value_type[COLOR]", value_type[COLOR])
value_type[PARTICLES] = buffer_read_byte()		debug("value_type[PARTICLES]", value_type[PARTICLES])
value_type[LIGHT] = buffer_read_byte()			debug("value_type[LIGHT]", value_type[LIGHT])
value_type[SPOTLIGHT] = buffer_read_byte()		debug("value_type[SPOTLIGHT]", value_type[SPOTLIGHT])
value_type[CAMERA] = buffer_read_byte()		   debug("value_type[CAMERA]", value_type[CAMERA])

if (load_format < project_100debug)
	value_type[TEXTURE] = buffer_read_byte() 

if (load_format >= project_100demo4)
	value_type[BACKGROUND] = buffer_read_byte()
else
	value_type[BACKGROUND] = false
debug("value_type[BACKGROUND]", value_type[BACKGROUND])

if (load_format >= project_100debug)
	value_type[TEXTURE] = buffer_read_byte() 
debug("value_type[TEXTURE]", value_type[TEXTURE])

if (load_format >= project_100debug)
{
	value_type[SOUND] = buffer_read_byte()
	value_type[KEYFRAME] = buffer_read_byte()
}
else
{
	value_type[SOUND] = false
	value_type[KEYFRAME] = true
}
debug("value_type[SOUND]", value_type[SOUND])
debug("value_type[KEYFRAME]", value_type[KEYFRAME])

value_type[ROTPOINT] = buffer_read_byte()		 debug("value_type[ROTPOINT]", value_type[ROTPOINT])

if (load_format >= project_100demo4)
{
	value_type[HIERARCHY] = buffer_read_byte()	debug("value_type[HIERARCHY]", value_type[HIERARCHY])
	value_type[GRAPHICS] = buffer_read_byte()	 debug("value_type[GRAPHICS]", value_type[GRAPHICS])
}

if (load_format < project_100debug) // Bug in demos
	value_type[HIERARCHY] = true
	value_type[GRAPHICS] = true

if (load_format >= project_100debug)
	value_type[AUDIO] = buffer_read_byte()
else
	value_type[AUDIO] = false
debug("value_type[AUDIO]", value_type[AUDIO])
