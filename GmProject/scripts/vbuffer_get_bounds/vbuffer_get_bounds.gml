/// CppSeparate VarType vbuffer_get_bounds(IntType, MatrixType)
/// @desc Returns transformed vertex buffer bounds as two points, or null if unavailable.
/// @arg vertexbuffer
/// @arg matrix

function vbuffer_get_bounds(vbuf, mat)
{
	return [ vec3(0), vec3(block_size) ]
}
