/// vbuffer_start()

vbuffer_current = vertex_create_buffer()
vertex_begin(vbuffer_current, vertex_format)
repeat (3) // Workaround vertex error
	vertex_add(0, 0, 0, 0, 0, 0, 0, 0)

return vbuffer_current
