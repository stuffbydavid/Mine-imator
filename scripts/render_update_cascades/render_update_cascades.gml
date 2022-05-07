/// render_update_cascades(direction)
/// @desc Updates sun cascades based on camera info.

function render_update_cascades(dir)
{
	// Get frustum for shadow cascades
	var mV = matrix_create_lookat(cam_from, cam_to, cam_up);
	var mP = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, cam_near, cam_far_prev);
	
	cam_frustum.build(matrix_multiply(mV, mP))
	cam_frustum.build_vbuffer()
	
	var startz, endz, disz, sunmatV;
	startz = cam_near
	endz = min(cam_far_prev, 7500)
	disz = endz - startz
	sunmatV = matrix_create_lookat(vec3(dir[X], dir[Y], dir[Z]), vec3(0), vec3(0, 0, 1));
	
	for (var i = 0; i < render_cascades_count; i++)
	{
		// Calculate frustum splits of the camera
		var cascade, zn, zf, submP;
		cascade = render_cascades[i]
		zn = cam_near + (render_cascade_ends[i] * disz)
		zf = cam_near + (render_cascade_ends[i + 1] * disz)
		submP = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, zn, zf);
		cascade.build(matrix_multiply(mV, submP))
		
		// Build debug vbuffer (Camera frustum split)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Get orthographic bounding box
		var orthoMin, orthoMax;
		orthoMin = [no_limit, no_limit, no_limit, no_limit]
		orthoMax = [-no_limit, -no_limit, -no_limit, -no_limit]
		
		// Frustum is built in world-space, convert to light space
		for (var j = 0; j < 8; j++)
		{
			var corner = vec4_mul_matrix(cascade.corners[j], sunmatV);
			orthoMin = vec4_min(orthoMin, corner)
			orthoMax = vec4_max(orthoMax, corner)
		}
		
		// Extend Z
		orthoMin[Z] = -30000
		orthoMax[Z] += 100
		
		// Fix shadow jittering
		var diagonalXY = abs(vec3_length(vec3_sub(cascade.corners[1], cascade.corners[4])));
		diagonalXY = max(diagonalXY, abs(vec3_length(vec3_sub(cascade.corners[1], cascade.corners[7]))))
		
		var borderOffset = vec4_mul(vec4_sub(vec4(diagonalXY), vec4_sub(orthoMax, orthoMin)), .5);
		borderOffset[Z] = 0
		borderOffset[W] = 0
		orthoMax = vec4_add(orthoMax, borderOffset)
		orthoMin = vec4_sub(orthoMin, borderOffset)

		// Snap to 1px increments to avoid shadow jittering
		var worldUnitsPerTexel = (diagonalXY / project_render_shadows_sun_buffer_size);
		orthoMin = vec4_div(orthoMin, worldUnitsPerTexel)
		orthoMin = vec4_floor(orthoMin)
		orthoMin = vec4_mul(orthoMin, worldUnitsPerTexel)
		
		orthoMax = vec4_div(orthoMax, worldUnitsPerTexel)
		orthoMax = vec4_floor(orthoMax)
		orthoMax = vec4_mul(orthoMax, worldUnitsPerTexel)
		
		var lightMatVinv = matrix_inverse(sunmatV);
        var lightPoints = [
            [orthoMin[X], orthoMax[Y], orthoMax[Z]],
            [orthoMin[X], orthoMin[Y], orthoMax[Z]],
            [orthoMax[X], orthoMin[Y], orthoMax[Z]],
            [orthoMax[X], orthoMax[Y], orthoMax[Z]],
            [orthoMin[X], orthoMax[Y], orthoMin[Z]],
            [orthoMin[X], orthoMin[Y], orthoMin[Z]],
            [orthoMax[X], orthoMin[Y], orthoMin[Z]],
            [orthoMax[X], orthoMax[Y], orthoMin[Z]]
        ];
		
		for (var j = 0; j < 8; j++)
			cascade.corners[j] = vec3_mul_matrix(lightPoints[j], lightMatVinv)
		
		// Build debug vbuffer (Ortho box)
		//cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		
		// Set projection for cascade
		cascade.near = orthoMin[Z]
		cascade.far = orthoMax[Z]
		cascade.matView = sunmatV
		cascade.matProj = matrix_create_ortho(orthoMin[X], orthoMax[X], orthoMax[Y], orthoMin[Y], -orthoMin[Z], -orthoMax[Z]);
		
		// Matrix for converting -1->1 to 0->1 in shader
		var matBias = [ 0.5,     0,   0, 0,
				          0,   0.5,   0, 0,
				          0,     0, 0.5, 0,
				          0.5, 0.5, 0.5, 1 ];
		
		cascade.matBias = matrix_multiply(matrix_multiply(cascade.matView, cascade.matProj), matBias)
		
		// Set clip end
		var vView = [0.0, 0.0, zf, 1.0];
		var vClip = vec4_mul_matrix(vView, mP);
		cascade.clipEndDepth = vClip[Z];
	}
}