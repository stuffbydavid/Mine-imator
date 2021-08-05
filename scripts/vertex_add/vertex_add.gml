/// vertex_add(x, y, z, nx, ny, nz, tx, ty)
/// vertex_add(pos, normal, texcoord)
/// @arg pos
/// @arg normal
/// @arg texcoord

function vertex_add()
{
	var xx, yy, zz;
	
	if (argument_count < 8)
	{
		var pos, normal, texcoord;
		pos = argument[0]
		normal = argument[1]
		texcoord = argument[2]
		
		xx = pos[@ X]
		yy = pos[@ Y]
		zz = pos[@ Z]
		
		vertex_position_3d(vbuffer_current, xx, yy, pos[@ Z])
		vertex_normal(vbuffer_current, normal[@ X], normal[@ Y], normal[@ Z])
		vertex_color(vbuffer_current, vertex_rgb, vertex_alpha)
		vertex_texcoord(vbuffer_current, texcoord[@ X], texcoord[@ Y])
		
		// Seperated for performance
		vbuffer_xmin = (xx < vbuffer_xmin ? xx : vbuffer_xmin)
		vbuffer_ymin = (yy < vbuffer_ymin ? yy : vbuffer_ymin)
		vbuffer_zmin = (zz < vbuffer_zmin ? zz : vbuffer_zmin)
		
		vbuffer_xmax = (xx > vbuffer_xmax ? xx : vbuffer_xmax)
		vbuffer_ymax = (yy > vbuffer_ymax ? yy : vbuffer_ymax)
		vbuffer_zmax = (zz > vbuffer_zmax ? zz : vbuffer_zmax)
	}
	else
	{
		xx = argument[0]
		yy = argument[1]
		zz = argument[2]
		
		vertex_position_3d(vbuffer_current, xx, yy, zz)
		vertex_normal(vbuffer_current, argument[3], argument[4], argument[5])
		vertex_color(vbuffer_current, vertex_rgb, vertex_alpha)
		vertex_texcoord(vbuffer_current, argument[6], argument[7])
		
		// Seperated for performance
		vbuffer_xmin = (xx < vbuffer_xmin ? xx : vbuffer_xmin)
		vbuffer_ymin = (yy < vbuffer_ymin ? yy : vbuffer_ymin)
		vbuffer_zmin = (zz < vbuffer_zmin ? zz : vbuffer_zmin)
		
		vbuffer_xmax = (xx > vbuffer_xmax ? xx : vbuffer_xmax)
		vbuffer_ymax = (yy > vbuffer_ymax ? yy : vbuffer_ymax)
		vbuffer_zmax = (zz > vbuffer_zmax ? zz : vbuffer_zmax)
	}
	
	var wavexy, wavez;
	wavexy = 0
	wavez = 0
	
	// Wave
	if (vertex_wave != e_vertex_wave.NONE)
	{
		// Vertex Z must be within zmin and zmax (if set)
		if ((vertex_wave_zmin = null || zz > vertex_wave_zmin) &&
			(vertex_wave_zmax = null || zz < vertex_wave_zmax))
		{
			if (vertex_wave = e_vertex_wave.ALL)
			{
				wavexy = 1
				wavez = 1
			}
			else if (vertex_wave = e_vertex_wave.Z_ONLY)
				wavez = 1
		}
	}
	
	// Custom
	vertex_float4(vbuffer_current, wavexy, wavez, vertex_brightness, vertex_subsurface)
}
