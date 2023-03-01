/// CppSeparate VecType vec4(VarType x, VarType y = VarType(), VarType z = VarType(), VarType w = VarType())
/// vec4(x, y, z, w)
/// @arg x
/// @arg y
/// @arg z
/// @arg w

function vec4(xx, yy = undefined, zz = undefined, w = undefined)
{
	gml_pragma("forceinline")
	
	if (yy = undefined)
		return [xx, xx, xx, xx]
	else
		return [xx, yy, zz, w]
}
