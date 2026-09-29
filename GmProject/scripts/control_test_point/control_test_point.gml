/// @desc Returns true if position is closer to camera than selected object.
/// @arg position
/// @arg timelineposition
/// @arg bias

function control_test_point(pos, tlpos, bias)
{
	var camdir, worlddis, pointdis;
	camdir = point3D_add(cam_from, vec3_mul(vec3_normalize(point3D_sub(cam_from, tlpos)), project_render_distance))
	worlddis = clamp(vec3_dot(vec3_sub(tlpos, cam_from), vec3_sub(camdir, cam_from)) / vec3_length(vec3_sub(camdir, cam_from)), -no_limit, no_limit)
	pointdis = clamp(vec3_dot(vec3_sub(pos,   cam_from), vec3_sub(camdir, cam_from)) / vec3_length(vec3_sub(camdir, cam_from)), -no_limit, no_limit)
	
	return (pointdis + bias < worlddis)
}
