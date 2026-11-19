function vbuffer_start()
{
	vbuffer_current = vertex_create_buffer()
	vertex_begin(vbuffer_current, vertex_format)
	
	if (!is_cpp())
		repeat (3) // Workaround vertex error
			vertex_add_real(0, 0, 0, 0, 0, 0, 0, 0)
	
	return vbuffer_current
}
