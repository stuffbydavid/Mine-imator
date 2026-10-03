function vertex_add_wave(z)
{
	var wavexy, wavez;
	wavexy = 0
	wavez = 0

	// Wind/custom values
	if (vertex_wave != e_vertex_wave.NONE)
	{
		// Vertex Z must be within zmin and zmax (if set)
		if ((vertex_wave_zmin = null || z > vertex_wave_zmin) &&
			(vertex_wave_zmax = null || z < vertex_wave_zmax))
		{
			if (vertex_wave = e_vertex_wave.ALL)
			{
				wavexy = 1
				wavez = 1
			}
			else if (vertex_wave = e_vertex_wave.Z_ONLY)
				wavez = 1
		}

		vertex_float4(vbuffer_current, wavexy, wavez, vertex_emissive, vertex_subsurface)
	}
	else
		vertex_float4(vbuffer_current, 0, 0, vertex_emissive, vertex_subsurface)

	vertex_float3(vbuffer_current, 0, 0, 0)
}
