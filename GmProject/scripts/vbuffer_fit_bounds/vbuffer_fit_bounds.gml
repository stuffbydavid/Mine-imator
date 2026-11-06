/// CppSeparate VarType vbuffer_fit_bounds(IntType, VecType)
/// @desc Fits a block box to its source triangles.
/// @arg vertexbuffer
/// @arg blockposition

function vbuffer_fit_bounds(vbuf, blockpos)
{
	var boxmin = vec3_mul(blockpos, block_size);
	return [ boxmin, vec3_add(boxmin, block_size) ]
}
