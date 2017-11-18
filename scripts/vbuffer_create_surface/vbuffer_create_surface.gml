/// vbuffer_create_surface(radius, texcoord1, texcoord2, invert)
/// @arg radius
/// @arg texcoord1
/// @arg texcoord2
/// @arg invert

var rad, tex1, tex2, invert;
rad = argument0
tex1 = argument1
tex2 = argument2
invert = argument3

vbuffer_start()

vbuffer_add_triangle(-rad, 0, rad, rad, 0, rad, rad, 0, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex2[X], tex2[Y], c_white, 1, invert)
vbuffer_add_triangle(-rad, 0, -rad, -rad, 0, rad, rad, 0, -rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex2[Y], c_white, 1, invert)

return vbuffer_done()
