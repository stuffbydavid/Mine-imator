/// @desc Updates sun cascades based on camera info.
/// @arg direction

function render_update_cascades(dir)
{
	// Get shadow distance from world bounds
	var mindis, snapsize, extent;
	mindis = 1000
	snapsize = block_size
	
	if (render_scene_bounds = null)
		render_scene_bounds = render_get_scene_bounds()
	
	// Bounds use XY, include camera height above the ground plane
	extent = vec3(
		max(abs(render_scene_bounds[0] - cam_from[X]), abs(render_scene_bounds[2] - cam_from[X])),
		max(abs(render_scene_bounds[1] - cam_from[Y]), abs(render_scene_bounds[3] - cam_from[Y])),
		cam_from[Z]
	)
	
	// Keep small camera movements from continuously resizing the shadow range
	render_shadow_distance = clamp(ceil(vec3_length(extent) / snapsize) * snapsize, min(mindis, cam_far_prev), cam_far_prev)
	
	// Define cascades
	switch (render_cascades_count)
	{
		case 1:
		{
			render_cascade_ends = [
				0,
				render_shadow_distance
			];
			break
		}
		
		case 2:
		{
			render_cascade_ends = [
				0,
				max(300, render_shadow_distance * 0.1),
				render_shadow_distance
			];
			break
		}
		
		case 3:
		{
			render_cascade_ends = [
				0,
				max(300, render_shadow_distance * 0.1), 
				max(600, render_shadow_distance * 0.25),
				render_shadow_distance
			];
			break
		}
	}

	var startz, endz, disz, sunmatv, sunup, lightatvinv, lightorigin;
	startz = cam_near
	endz = max(startz + 0.001, render_shadow_distance)
	disz = endz - startz
	
	// Camera-relative depth keeps caster coverage independent of the world origin
	sunup = abs(dir[Z]) < 0.999 ? vec3(0, 0, 1) : vec3(0, 1, 0)
	sunmatv = matrix_create_lookat(cam_from, vec3_sub(cam_from, dir), sunup)
	lightatvinv = matrix_inverse_ext(sunmatv)
	lightorigin = vec3_mul_matrix(cam_from, sunmatv)
	
	// Get frustum for shadow cascades
	var mv, mp;
	mv = matrix_create_lookat(cam_from, cam_to, cam_up)
	mp = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, cam_near, cam_far_prev)
	
	for (var i = 0; i < render_cascades_count; i++)
	{
		// Calculate frustum splits of the camera
		var cascade, zn, zf, submp;
		cascade = render_cascades[i]
		zn = startz + render_cascade_ends[i]
		zf = startz + render_cascade_ends[i + 1]
		submp = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, zn, zf)
		cascade.build(matrix_multiply(mv, submp))
		
		// Build debug vbuffer (Camera frustum split)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Get orthographic bounding box
		var orthomin, orthomax;
		orthomin = [ no_limit, no_limit, no_limit, no_limit ]
		orthomax = [ -no_limit, -no_limit, -no_limit, -no_limit ]
		
		// Frustum is built in world-space, convert to light space
		for (var j = 0; j < 8; j++)
		{
			var corner = vec4_mul_matrix(cascade.corners[j], sunmatv);
			orthomin = vec4_min(orthomin, corner)
			orthomax = vec4_max(orthomax, corner)
		}
		
		// Get longest diagonal to fix jittering
		var diagonalxy = vec3_length(vec3_sub(cascade.corners[1], cascade.corners[3]));
		diagonalxy = max(diagonalxy, vec3_length(vec3_sub(cascade.corners[1], cascade.corners[7])))
		
		// Keep the world-anchored texel grid stable between range steps
		diagonalxy = ceil(diagonalxy / snapsize) * snapsize
		
		// Reserve a texel on each edge before snapping the center
		diagonalxy *= project_render_shadows_sun_buffer_size / max(1, project_render_shadows_sun_buffer_size - 2)
		cascade.worldSize = diagonalxy
		
		// Snap to a world-anchored texel grid without changing the square extent
		var pixelsize, centerx, centery, depthpadding;
		pixelsize = diagonalxy / project_render_shadows_sun_buffer_size
		centerx = (orthomin[X] + orthomax[X]) * 0.5 + lightorigin[X]
		centery = (orthomin[Y] + orthomax[Y]) * 0.5 + lightorigin[Y]
		centerx = round(centerx / pixelsize) * pixelsize - lightorigin[X]
		centery = round(centery / pixelsize) * pixelsize - lightorigin[Y]
		orthomin[X] = centerx - diagonalxy * 0.5
		orthomax[X] = centerx + diagonalxy * 0.5
		orthomin[Y] = centery - diagonalxy * 0.5
		orthomax[Y] = centery + diagonalxy * 0.5
		
		// Include offscreen casters toward the sun, with scale-aware depth padding
		depthpadding = max(1, pixelsize)
		orthomin[Z] -= disz + depthpadding
		orthomax[Z] += depthpadding
		
		var lightpoints = [
			point3D(orthomin[X], orthomax[Y], orthomax[Z]),
			point3D(orthomin[X], orthomin[Y], orthomax[Z]),
			point3D(orthomax[X], orthomin[Y], orthomax[Z]),
			point3D(orthomax[X], orthomax[Y], orthomax[Z]),
			point3D(orthomin[X], orthomax[Y], orthomin[Z]),
			point3D(orthomin[X], orthomin[Y], orthomin[Z]),
			point3D(orthomax[X], orthomin[Y], orthomin[Z]),
			point3D(orthomax[X], orthomax[Y], orthomin[Z])
		]
		
		for (var j = 0; j < 8; j++)
			cascade.corners[j] = point3D_mul_matrix(lightpoints[j], lightatvinv)
		
		// Build debug vbuffer (Ortho box)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Set projection for cascade
		cascade.near = orthomin[Z]
		cascade.far = orthomax[Z]
		cascade.matView = sunmatv
		cascade.matProj = matrix_create_ortho(orthomin[X], orthomax[X], orthomax[Y], orthomin[Y], -orthomin[Z], -orthomax[Z])
		
		// Matrix for converting -1->1 to 0->1 in shader
		var matbias = [ 0.5, 0,   0,   0,
						0,	 0.5, 0,   0,
						0,   0,   0.5, 0,
						0.5, 0.5, 0.5, 1 ];
		
		cascade.matBias = matrix_multiply(matrix_multiply(cascade.matView, cascade.matProj), matbias)
		
		// D3D clips native depth to 0->1, keep the full caster range
		if (is_cpp() && graphics_api_get() = "D3D")
		{
			cascade.matProj = matrix_multiply(
				cascade.matProj,
				[ 1, 0, 0,  0,
				  0, 1, 0,  0,
				  0, 0, 0.5, 0,
				  0 ,0, 0.5, 1 ]
			)
		}
		
		// Set clip end
		var vview, vclip;
		vview = vec4(0.0, 0.0, zf, 1.0)
		vclip = vec4_mul_matrix(vview, mp)
		cascade.clipEndDepth = vclip[Z]
	}
}
