/// CppSeparate MatrixType matrix_create(VecType, VecType, VecType)
/// matrix_create(position, rotation, scale)
/// @arg position
/// @arg rotation
/// @arg scale

function matrix_create(pos, rot, sca)
{
	gml_pragma("forceinline")
	
	return matrix_build(pos[@ X], pos[@ Y], pos[@ Z], rot[@ X], rot[@ Y], rot[@ Z], sca[@ X], sca[@ Y], sca[@ Z])
}
