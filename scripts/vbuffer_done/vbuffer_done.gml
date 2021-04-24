/// vbuffer_done([vbuffer])
/// @arg [vbuffer]

function vbuffer_done()
{
	var vbuffer = vbuffer_current;
	if (argument_count > 0)
		vbuffer_current = argument[0]
	
	vertex_end(vbuffer)
	vertex_freeze(vbuffer)
	
	return vbuffer
}
