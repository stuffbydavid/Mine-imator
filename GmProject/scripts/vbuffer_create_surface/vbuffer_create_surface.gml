/// vbuffer_create_surface(radius, texcoord1, texcoord2, invert)
/// @arg radius
/// @arg texcoord1
/// @arg texcoord2
/// @arg invert

function vbuffer_create_surface(rad, tex1, tex2, invert)
{
	vbuffer_start()
	
	vbuffer_add_triangle(-rad, 0, rad, rad, 0, rad, rad, 0, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex2[X], tex2[Y], invert)
	vbuffer_add_triangle(-rad, 0, -rad, -rad, 0, rad, rad, 0, -rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex2[Y], invert)
	
	return vbuffer_done()
}
