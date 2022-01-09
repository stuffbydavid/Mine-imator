/// vec2(x, y)
/// @arg x
/// @arg y

function vec2(xx, yy)
{
	gml_pragma("forceinline")
	
	if (yy = undefined)
		return [xx, xx]
	else
		return [xx, yy]
}
