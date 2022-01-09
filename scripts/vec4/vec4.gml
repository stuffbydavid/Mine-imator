/// vec4(x, y, z, w)
/// @arg x
/// @arg y
/// @arg z
/// @arg w

function vec4(xx, yy, zz, w)
{
	gml_pragma("forceinline")
	
	if (yy = undefined)
		return [xx, xx, xx, xx]
	else
		return [xx, yy, zz, w]
}
