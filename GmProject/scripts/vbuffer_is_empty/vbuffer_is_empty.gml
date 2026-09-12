/// vbuffer_is_empty(vbuffer)
/// @arg vbuffer

function vbuffer_is_empty(vbuf)
{
	return (vertex_get_number(vbuf) = (is_cpp() ? 0 : 3))
}
