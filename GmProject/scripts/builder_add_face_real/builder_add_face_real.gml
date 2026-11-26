/// CppSeparate void builder_add_face_real(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)

function builder_add_face_real(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, tx1, ty1, tx2, ty2, tx3, ty3, tx4, ty4, matrix)
{
	builder_add_triangle_real(
		x1, y1, z1, x2, y2, z2, x3, y3, z3,
		tx1, ty1, tx2, ty2, tx3, ty3,
		matrix
	)
	builder_add_triangle_real(
		x3, y3, z3, x4, y4, z4, x1, y1, z1,
		tx3, ty3, tx4, ty4, tx1, ty1,
		matrix
	)
}
