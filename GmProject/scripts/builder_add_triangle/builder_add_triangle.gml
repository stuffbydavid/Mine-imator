/// CppSeparate void builder_add_triangle(Scope<obj_builder_thread>, VecType, VecType, VecType, VecType, VecType, VecType, VarType)

function builder_add_triangle(pos1, pos2, pos3, tex1, tex2, tex3, matrix)
{
	builder_add_triangle_real(
		pos1[X], pos1[Y], pos1[Z],
		pos2[X], pos2[Y], pos2[Z],
		pos3[X], pos3[Y], pos3[Z],
		tex1[X], tex1[Y],
		tex2[X], tex2[Y],
		tex3[X], tex3[Y],
		matrix)
}
