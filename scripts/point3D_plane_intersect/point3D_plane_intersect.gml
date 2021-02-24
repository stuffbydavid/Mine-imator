/// point3D_plane_intersect(origin, normal, raypos, direction)
/// @arg origin
/// @arg normal
/// @arg raypos
/// @arg direction

var planepos, planenormal, raypos, raydir, dist;
planepos = argument0
planenormal = argument1
raypos = argument2
raydir = argument3

// 'Max' dot product to prevent dividing by 0, occurs when ray direction doesn't hit plane
dist = vec3_dot(vec3_sub(planepos, raypos), planenormal) / max(vec3_dot(planenormal, raydir), 0.0001)

return vec3_add(raypos, vec3_mul(raydir, dist))
