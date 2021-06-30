/// vbuffer_start()

function vbuffer_start()
{
	vbuffer_current = vertex_create_buffer()
	vertex_begin(vbuffer_current, vertex_format)
	repeat (3) // Workaround vertex error
		vertex_add(0, 0, 0, 0, 0, 0, 0, 0)
	
	vbuffer_xmin = no_limit
	vbuffer_ymin = no_limit
	vbuffer_zmin = no_limit
	vbuffer_xmax = -no_limit
	vbuffer_ymax = -no_limit
	vbuffer_zmax = -no_limit
	
	return vbuffer_current
}
