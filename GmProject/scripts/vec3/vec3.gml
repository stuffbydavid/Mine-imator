/// CppSeparate VecType vec3(VarType x, VarType y = VarType(), VarType z = VarType())
/// @arg x
/// @arg [y]
/// @arg [z]

function vec3(xx, yy = undefined, zz = undefined)
{
	gml_pragma("forceinline")
	
	if (is_undefined(yy))
		return [xx, xx, xx]
	else
		return [xx, yy, zz]
}
