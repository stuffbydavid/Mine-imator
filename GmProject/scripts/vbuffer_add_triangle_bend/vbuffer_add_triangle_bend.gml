/// @desc Adds static GPU bend data or uses the ordinary CPU triangle path
function vbuffer_add_triangle_bend(pos1, pos2, pos3, tex1, tex2, tex3, normal1 = null, normal2 = null, normal3 = null, invert = false)
{
	if (is_cpp() && array_length(pos1) = 4)
	{
		var zmin = vertex_wave_zmin = null ? -1000000000000000000000000000000.0 : real(vertex_wave_zmin);
		var zmax = vertex_wave_zmax = null ? 1000000000000000000000000000000.0 : real(vertex_wave_zmax);
		vertex_bend_triangle(vbuffer_current, pos1, pos2, pos3,
			vec2(tex1[X], tex1[Y]), vec2(tex2[X], tex2[Y]), vec2(tex3[X], tex3[Y]),
			normal1, normal2, normal3, invert, c_white, 1, vertex_emissive,
			vertex_wave, zmin, zmax, vertex_subsurface_color_index)
	}
	else
		vbuffer_add_triangle(pos1, pos2, pos3, tex1, tex2, tex3, normal1, normal2, normal3, invert)
}
