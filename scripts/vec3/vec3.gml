/// vec3(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function vec3(xx, yy, zz)
{
	if (yy = undefined)
		return [xx, xx, xx]
	else
		return [xx, yy, zz]
}
