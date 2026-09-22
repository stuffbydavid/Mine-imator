/// vec3_snap(vec, val)
/// @arg vec
/// @arg val

function vec3_snap(vec, val)
{
	return vec3(
		snap(vec[@X], val),
		snap(vec[@Y], val),
		snap(vec[@Z], val)
	)
}