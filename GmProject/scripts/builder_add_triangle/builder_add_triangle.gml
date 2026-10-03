/// CppSeparate void builder_add_triangle(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)

function builder_add_triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, tx1, ty1, tx2, ty2, tx3, ty3, matrix)
{
	vbuffer_current = block_vbuffer_current
	vertex_wave = block_vertex_wave
	vertex_wave_zmin = block_vertex_wave_zmin
	vertex_wave_zmax = block_vertex_wave_zmax
	vertex_emissive = block_vertex_emissive
	vertex_subsurface = block_vertex_subsurface
	vertex_rgb = block_vertex_rgb
	
	vbuffer_add_triangle_real(
		x1, y1, z1,
		x2, y2, z2,
		x3, y3, z3,
		tx1, ty1,
		tx2, ty2,
		tx3, ty3,
		false, matrix
	)
}
