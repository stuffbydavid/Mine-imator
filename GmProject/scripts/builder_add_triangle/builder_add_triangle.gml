/// CppSeparate void builder_add_triangle(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)
function builder_add_triangle()
{
	vbuffer_current = block_vbuffer_current
	vertex_wave = block_vertex_wave
	vertex_wave_zmin = block_vertex_wave_zmin
	vertex_wave_zmax = block_vertex_wave_zmax
	vertex_emissive = block_vertex_emissive
	vertex_subsurface = block_vertex_subsurface
	vertex_rgb = block_vertex_rgb
	
	vbuffer_add_triangle(
		argument[0], argument[1], argument[2],
		argument[3], argument[4], argument[5],
		argument[6], argument[7], argument[8],
		argument[9], argument[10],
		argument[11], argument[12],
		argument[13], argument[14],
		false, argument[15]
	)
}