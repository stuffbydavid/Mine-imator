/// vec2(x, y)
/// @arg x
/// @arg y

function vec2(xx, yy)
{
	if (yy = undefined)
		return [xx, xx]
	else
		return [xx, yy]
}
