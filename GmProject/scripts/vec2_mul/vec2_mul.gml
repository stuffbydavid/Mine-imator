/// CppSeparate VecType vec2_mul(VecType, VarType)
/// @arg vector
/// @arg multiplier

function vec2_mul(vec, mul)
{
	gml_pragma("forceinline")
	
	if (is_array(mul))
		return [vec[@ X] * mul[@ X], vec[@ Y] * mul[@ Y]]
	else
		return [vec[@ X] * mul, vec[@ Y] * mul]
}
