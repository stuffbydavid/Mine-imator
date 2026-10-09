/// CppSeparate VecType vec2(VarType x, VarType y = VarType())
/// @arg x
/// @arg [y]

function vec2(xx, yy = undefined)
{
	gml_pragma("forceinline")
	
	if (is_undefined(yy))
		return [ xx, xx ]
	else
		return [ xx, yy ]
}
