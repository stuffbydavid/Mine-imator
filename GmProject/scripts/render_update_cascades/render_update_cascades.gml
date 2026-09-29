/// @desc Updates sun cascades based on camera info.
/// @arg direction

function render_update_cascades(dir)
{
	if (render_cascades_count = 1)
		render_cascade_ends = [0.0, 0.05]
	else if (render_cascades_count = 2)
		render_cascade_ends = [0.0, 0.035, 0.2]
	else
		render_cascade_ends = [0.0, 0.035, 0.15, 1.0]

	// Get frustum for shadow cascades
	var mv = matrix_create_lookat(cam_from, cam_to, cam_up);
	var mp = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, cam_near, cam_far_prev);
	
	cam_frustum.build(matrix_multiply(mv, mp))
	cam_frustum.build_vbuffer()
	
	var startz, endz, disz, sunmatv;
	startz = cam_near
	endz = min(cam_far_prev, 7500)
	disz = endz - startz
	sunmatv = matrix_create_lookat(vec3(dir[X], dir[Y], dir[Z]), vec3(0), vec3(0, 0, 1))
	
	for (var i = 0; i < render_cascades_count; i++)
	{
		// Calculate frustum splits of the camera
		var cascade, zn, zf, submp;
		cascade = render_cascades[i]
		zn = (cam_near + (render_cascade_ends[i] * disz))
		zf = (cam_near + (render_cascade_ends[i + 1] * disz))
		submp = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, zn, zf)
		cascade.build(matrix_multiply(mv, submp))
		
		// Build debug vbuffer (Camera frustum split)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Get orthographic bounding box
		var orthomin, orthomax;
		orthomin = [no_limit, no_limit, no_limit, no_limit]
		orthomax = [-no_limit, -no_limit, -no_limit, -no_limit]
		
		// Frustum is built in world-space, convert to light space
		for (var j = 0; j < 8; j++)
		{
			var corner = vec4_mul_matrix(cascade.corners[j], sunmatv);
			orthomin = vec4_min(orthomin, corner)
			orthomax = vec4_max(orthomax, corner)
		}
		
		// Extend Z
		orthomin[Z] = -30000
		orthomax[Z] += 100
		
		// Get longest diagonal to fix jittering
		var diagonalxy = vec3_length(vec3_sub(cascade.corners[1], cascade.corners[3]));
		diagonalxy = max(diagonalxy, vec3_length(vec3_sub(cascade.corners[1], cascade.corners[7])))
		cascade.worldSize = diagonalxy
		
		// Force square width/height (jitter fix 1)
		var w, h, dif;
		w = orthomax[X] - orthomin[X]
		h = orthomax[Y] - orthomin[Y]
		
		dif = diagonalxy - h
		if (dif > 0)
		{
			orthomax[Y] += dif / 2
			orthomin[Y] -= dif / 2
		}
		
		dif = diagonalxy - w
		if (dif > 0)
		{
			orthomax[X] += dif / 2
			orthomin[X] -= dif / 2
		}
		
		// Round pixel size (jitter fix 2)
		var pixelsize = diagonalxy / project_render_shadows_sun_buffer_size;
		orthomax[X] = round(orthomax[X] / pixelsize) * pixelsize
		orthomin[X] = round(orthomin[X] / pixelsize) * pixelsize
		orthomax[Y] = round(orthomax[Y] / pixelsize) * pixelsize
		orthomin[Y] = round(orthomin[Y] / pixelsize) * pixelsize
		
		var lightatvinv = matrix_inverse_ext(sunmatv);
		var lightpoints = [
			point3D(orthomin[X], orthomax[Y], orthomax[Z]),
			point3D(orthomin[X], orthomin[Y], orthomax[Z]),
			point3D(orthomax[X], orthomin[Y], orthomax[Z]),
			point3D(orthomax[X], orthomax[Y], orthomax[Z]),
			point3D(orthomin[X], orthomax[Y], orthomin[Z]),
			point3D(orthomin[X], orthomin[Y], orthomin[Z]),
			point3D(orthomax[X], orthomin[Y], orthomin[Z]),
			point3D(orthomax[X], orthomax[Y], orthomin[Z])
		];
		
		for (var j = 0; j < 8; j++)
			cascade.corners[j] = vec3_mul_matrix(lightpoints[j], lightatvinv)
		
		// Build debug vbuffer (Ortho box)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Set projection for cascade
		cascade.near = orthomin[Z]
		cascade.far = orthomax[Z]
		cascade.matView = sunmatv
		cascade.matProj = matrix_create_ortho(orthomin[X], orthomax[X], orthomax[Y], orthomin[Y], -orthomin[Z], -orthomax[Z])
		
		// Matrix for converting -1->1 to 0->1 in shader
		var matbias = [ 0.5,     0,   0, 0,
						  0,   0.5,   0, 0,
						  0,     0, 0.5, 0,
						  0.5, 0.5, 0.5, 1 ];
		
		cascade.matBias = matrix_multiply(matrix_multiply(cascade.matView, cascade.matProj), matbias)
		
		// Set clip end
		var vview = vec4(0.0, 0.0, zf, 1.0);
		var vclip = vec4_mul_matrix(vview, mp);
		cascade.clipEndDepth = vclip[Z]
	}
}
