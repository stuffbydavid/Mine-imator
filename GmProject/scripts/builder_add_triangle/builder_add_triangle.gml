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
	
	if (build_transform)
	{
		var height = build_size_x * block_size;
		
		// Apply element transforms before changing builder axes
		if (matrix != null)
		{
			var p1, p2, p3;
			p1 = point3D_mul_matrix(point3D(x1, y1, z1), matrix)
			p2 = point3D_mul_matrix(point3D(x2, y2, z2), matrix)
			p3 = point3D_mul_matrix(point3D(x3, y3, z3), matrix)
			x1 = p1[Y]; y1 = height - p1[X]; z1 = p1[Z];
			x2 = p2[Y]; y2 = height - p2[X]; z2 = p2[Z];
			x3 = p3[Y]; y3 = height - p3[X]; z3 = p3[Z];
		}
		else
		{
			var oldx;
			oldx = x1; x1 = y1; y1 = height - oldx;
			oldx = x2; x2 = y2; y2 = height - oldx;
			oldx = x3; x3 = y3; y3 = height - oldx;
		}
		
		matrix = null
	}
	
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
