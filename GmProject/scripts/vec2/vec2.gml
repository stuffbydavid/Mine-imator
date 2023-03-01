/// CppSeparate VecType vec2(VarType x, VarType y = VarType())
/// vec2(x, y)
/// @arg x
/// @arg y

function vec2(xx, yy = undefined)
{
	gml_pragma("forceinline")
	
	if (yy = undefined)
		return [xx, xx]
	else
		return [xx, yy]
}
