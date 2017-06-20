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
	texcoord = vec2(argument[6], argument[7])
	if (argument_count > 8)
		color = argument[8]
	else
		color = -1
}
		
vertex_position_3d(vbuffer_current, pos[@ X], pos[@ Y], pos[@ Z])
vertex_normal(vbuffer_current, normal[@ X], normal[@ Y], normal[@ Z])
vertex_texcoord(vbuffer_current, texcoord[@ X], texcoord[@ Y])
vertex_color(vbuffer_current, color, 1)

// Wave
var wavexy, wavez;
wavexy = 0
wavez = 0

if (vertex_wave_minz = null || pos[@ Z] > vertex_wave_minz)
{
	if (vertex_wave = e_vertex_wave.ALL)
	{
		wavexy = 1
		wavez = 1
	}
	else if (vertex_wave = e_vertex_wave.Z_ONLY)
		wavez = 1
}

// Custom
vertex_float3(vbuffer_current, wavexy, wavez, vertex_brightness)