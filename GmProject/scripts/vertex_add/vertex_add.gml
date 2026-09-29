/// @arg position
/// @arg normal
/// @arg texcoord

function vertex_add(pos, normal, texcoord)
{
	vertex_position_3d(vbuffer_current, pos[@ X], pos[@ Y], pos[@ Z])
	vertex_normal(vbuffer_current, normal[@ X], normal[@ Y], normal[@ Z])
	vertex_color(vbuffer_current, vertex_rgb, vertex_alpha)
	vertex_texcoord(vbuffer_current, texcoord[@ X], texcoord[@ Y])
	
	vertex_add_wave(pos[@ Z])
}
