/// vertex_format_startup()

function vertex_format_startup()
{
	globalvar vbuffer_current, vertex_format, vertex_wave, vertex_wave_zmin, vertex_wave_zmax, vertex_emissive, vertex_subsurface;
	globalvar vertex_rgb, vertex_alpha;
	
	log("Create vertex format")
	vertex_format_begin()
	vertex_format_add_position_3d()
	vertex_format_add_normal()
	vertex_format_add_colour()
	vertex_format_add_texcoord()
	vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord) // Wind(XY), Emissive(Z), Subsurface(W)
	vertex_format_add_custom(vertex_type_float3, vertex_usage_texcoord) // Tangent
	vertex_format = vertex_format_end()
	
	vertex_rgb = c_white
	vertex_alpha = 1
	
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	vertex_emissive = 0
	vertex_subsurface = 0
}
