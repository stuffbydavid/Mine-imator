/// @arg [vertexbuffer]

function vbuffer_done(vbuf = null)
{
	if (vbuf = null)
		vbuf = vbuffer_current
	
	vertex_end(vbuf)
	vbuf = vbuffer_generate_tangents(vbuf)
	vertex_freeze(vbuf)
	
	return vbuf
}
