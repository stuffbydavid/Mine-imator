/// CppSeparate VecType vec4(VarType x, VarType y = VarType(), VarType z = VarType(), VarType w = VarType())
/// @arg x
/// @arg [y]
/// @arg [z]
/// @arg [w]

function vec4(xx, yy = undefined, zz = undefined, w = undefined)
{
	gml_pragma("forceinline")
	
	if (is_undefined(yy))
		return [xx, xx, xx, xx]
	else
		return [xx, yy, zz, w]
}
