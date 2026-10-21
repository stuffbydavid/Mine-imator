/// @arg rayorigin
/// @arg raydirection
/// @arg planeorigin
/// @arg planenormal

function ray_plane_intersect(raypos, raydir, planepos, planenormal)
{
	// 'Max' dot product to prevent dividing by 0, occurs when ray direction doesn't hit plane
	var dist = vec3_dot(vec3_sub(planepos, raypos), planenormal) / max(vec3_dot(planenormal, raydir), 0.0001);
	
	return vec3_add(raypos, vec3_mul(raydir, dist))
}
