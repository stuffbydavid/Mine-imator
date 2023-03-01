/// CppSeparate VecType vec3(VarType x, VarType y = VarType(), VarType z = VarType())
/// vec3(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function vec3(xx, yy = undefined, zz = undefined)
{
	gml_pragma("forceinline")
	
	if (yy = undefined)
		return [xx, xx, xx]
	else
		return [xx, yy, zz]
}
