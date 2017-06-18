/// vertex_add(x, y, z, nx, ny, nz, tx, ty, [color])
/// vertex_add(pos, normal, texcoord, [color])
/// @arg pos
/// @arg normal
/// @arg texcoord
/// @arg [color]

var pos, normal, texcoord, color;
	
if (argument_count < 8)
{
	pos = argument[0]
	normal = argument[1]
	texcoord = argument[2]
	
	if (argument_count > 3) 
		color = argument[3]
	else
		color = -1
}
else
{
	pos = point3D(argument[0], argument[1], argument[2])
	normal = vec3(argument[3], argument[4], argument[5])
	texcoord = point2D(argument[6], argument[7])
	if (argument_count > 8)
		color = argument[8]
	else
		color = -1
}
		
vertex_position_3d(vbuffer_current, pos[@ X], pos[@ Y], pos[@ Z])
vertex_normal(vbuffer_current, normal[@ X], normal[@ Y], normal[@ Z])
vertex_texcoord(vbuffer_current, texcoord[@ X], texcoord[@ Y])
vertex_color(vbuffer_current, color, 1)
vertex_float3(vbuffer_current, vertex_wave_xy, vertex_wave_z, vertex_brightness)