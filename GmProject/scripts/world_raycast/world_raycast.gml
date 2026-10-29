/// CppSeparate ArrType world_raycast(IntType, VecType, VecType, RealType, BoolType)
/// @desc Intersects world triangles without sampling textures or alpha

function world_raycast(view, origin, dir, distance, placing)
{
	return [ false, distance, vec3_add(origin, vec3_mul(dir, distance)), vec3(0), e_dir.amount, 0 ]
}
