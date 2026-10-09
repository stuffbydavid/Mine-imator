/// @desc Updates sun cascades based on camera info.
/// @arg direction

function render_update_cascades(dir)
{
	var mindis, pool, scenemin, scenemax, extent, far, distance, rangechanged;
	mindis = 1000
	pool = render_surface_pool_current
	
	if (render_scene_bounds = null)
		render_scene_bounds = render_get_scene_bounds()
	
	scenemin = render_scene_bounds[0]
	scenemax = render_scene_bounds[1]
	
	// Bounds use XY, include the camera height above the ground plane
	extent = vec3(
		max(abs(scenemin[X] - cam_from[X]), abs(scenemax[X] - cam_from[X])),
		max(abs(scenemin[Y] - cam_from[Y]), abs(scenemax[Y] - cam_from[Y])),
		cam_from[Z]
	)
	
	far = cam_far_prev
	if (env_fog_show && env_fog_height > scenemax[Z])
		far = min(env_fog_distance, far)
	
	distance = min(far, max(mindis, ceil(vec3_length(extent) * 1.1 / mindis) * mindis))
	rangechanged = (
		pool.sun_shadow_distance = 0 || distance > pool.sun_shadow_distance ||
		pool.sun_shadow_camera != render_camera || pool.sun_shadow_far != far || array_length(pool.sun_shadow_bounds) != 2 ||
		!vec3_equals(pool.sun_shadow_bounds[0], scenemin) || !vec3_equals(pool.sun_shadow_bounds[1], scenemax)
	)
	
	if (rangechanged)
	{
		pool.sun_shadow_distance = distance
		pool.sun_shadow_far = far
		pool.sun_shadow_camera = render_camera
		pool.sun_shadow_bounds = [ point3D_copy(scenemin), point3D_copy(scenemax) ]
	}
	
	render_shadow_distance = pool.sun_shadow_distance
	
	// Cached depth maps must retain the matrices used to render them
	var fitsettings, fitchanged;
	fitsettings = [ cam_near, cam_fov, render_ratio, render_cascades_count, project_render_shadows_sun_buffer_size, dir[X], dir[Y], dir[Z] ]
	fitchanged = (rangechanged || !array_equals(pool.sun_fit_settings, fitsettings))
	
	if (fitchanged)
	{
		for (var i = 0; i < 3; i++)
			ds_map_delete(render_shadow_cache_ready, "sun" + string(i))
		
		pool.sun_fit_settings = fitsettings
	}
	
	// Define cascades
	var cascades, dis1, dis2;
	dis1 = max(300, render_shadow_distance * 0.1)
	dis2 = max(600, render_shadow_distance * 0.25)
	switch (render_cascades_count)
	{
		case 1: cascades = [ 0, render_shadow_distance ]; break
		case 2: cascades = [ 0, dis1, render_shadow_distance ]; break
		case 3: cascades = [ 0, dis1, dis2, render_shadow_distance ]; break
	}

	var startz, endz, disz, sunmatv, sunup, sceneorigin, scenedepth, scenehalf;
	startz = cam_near
	endz = max(startz + 0.001, render_shadow_distance)
	disz = endz - startz
	
	// Anchor the light basis to the cached scene bounds
	sceneorigin = point3D((scenemin[X] + scenemax[X]) * 0.5, (scenemin[Y] + scenemax[Y]) * 0.5, 0)
	scenehalf = point3D((scenemax[X] - scenemin[X]) * 0.5, (scenemax[Y] - scenemin[Y]) * 0.5, 0)
	sunup = abs(dir[Z]) < 0.999 ? vec3(0, 0, 1) : vec3(0, 1, 0)
	sunmatv = matrix_create_lookat(sceneorigin, vec3_sub(sceneorigin, dir), sunup)
	scenedepth = abs(sunmatv[@ 2]) * scenehalf[X] + abs(sunmatv[@ 6]) * scenehalf[Y]
	
	// Get camera projection and rotation-independent frustum dimensions
	var mp, forward, slopesquared, radiuspadding, matbias, matdepth, d3d;
	mp = matrix_build_projection_perspective_fov(-cam_fov, -render_ratio, cam_near, cam_far_prev)
	forward = vec3_direction(cam_from, cam_to)
	slopesquared = sqr(tan(degtorad(cam_fov) * 0.5)) * (1 + sqr(render_ratio))
	radiuspadding = project_render_shadows_sun_buffer_size / max(1, project_render_shadows_sun_buffer_size - 2)
	
	// Convert -1->1 to 0->1 for shader sampling and native D3D depth
	matbias = [ 0.5, 0, 0, 0,
				0, 0.5, 0, 0,
				0, 0, 0.5, 0,
				0.5, 0.5, 0.5, 1 ]
	matdepth = [ 1, 0, 0, 0,
				 0, 1, 0, 0,
				 0, 0, 0.5, 0,
				 0, 0, 0.5, 1 ]
	d3d = (is_cpp() && graphics_api_get() = "D3D")
	
	for (var i = 0; i < render_cascades_count; i++)
	{
		if (render_shadow_cache_enabled && ds_map_exists(render_shadow_cache_ready, "sun" + string(i)))
			continue
		
		// Calculate frustum splits of the camera
		var cascade, zn, zf;
		cascade = render_cascades[i]
		zn = startz + cascades[i]
		zf = startz + cascades[i + 1]
		
		// Fit a sphere whose radius does not change with camera rotation
		var centerdistance, radius, center;
		centerdistance = min((zn + zf) * (1 + slopesquared) * 0.5, zf)
		radius = sqrt(max(sqr(centerdistance - zn) + slopesquared * sqr(zn), sqr(zf - centerdistance) + slopesquared * sqr(zf)))
		center = point3D_mul_matrix(vec3_add(cam_from, vec3_mul(forward, centerdistance)), sunmatv)
		
		// Leave one texel on each edge so alignment cannot clip receivers
		radius *= radiuspadding
		cascade.worldSize = radius * 2
		
		// Align the center to a scene-anchored texel grid without rounding the range
		var pixelsize, centerx, centery, depthpadding, orthomin, orthomax;
		pixelsize = cascade.worldSize / project_render_shadows_sun_buffer_size
		centerx = round(center[X] / pixelsize) * pixelsize
		centery = round(center[Y] / pixelsize) * pixelsize
		
		// Keep depth scale fixed too, with conservative coverage for the XY-only bounds
		depthpadding = max(1, pixelsize)
		orthomin = [ centerx - radius, centery - radius, center[Z] - radius - scenedepth - disz - depthpadding, 1 ]
		orthomax = [ centerx + radius, centery + radius, center[Z] + radius + scenedepth + depthpadding, 1 ]
		
		if (false) // Debug cascade bounds
		{
			var lightpoints, lightatvinv;
			lightpoints = [
				point3D(orthomin[X], orthomax[Y], orthomax[Z]),
				point3D(orthomin[X], orthomin[Y], orthomax[Z]),
				point3D(orthomax[X], orthomin[Y], orthomax[Z]),
				point3D(orthomax[X], orthomax[Y], orthomax[Z]),
				point3D(orthomin[X], orthomax[Y], orthomin[Z]),
				point3D(orthomin[X], orthomin[Y], orthomin[Z]),
				point3D(orthomax[X], orthomin[Y], orthomin[Z]),
				point3D(orthomax[X], orthomax[Y], orthomin[Z])
			]
			lightatvinv = matrix_inverse_ext(sunmatv)
			
			for (var j = 0; j < 8; j++)
				cascade.corners[j] = point3D_mul_matrix(lightpoints[j], lightatvinv)
			
			cascade.build_vbuffer(i = 0 ? c_red : (i = 1 ? c_lime : c_blue))
		}
		
		// Set projection for cascade
		cascade.near = orthomin[Z]
		cascade.far = orthomax[Z]
		cascade.matView = sunmatv
		cascade.matProj = matrix_create_ortho(orthomin[X], orthomax[X], orthomax[Y], orthomin[Y], -orthomin[Z], -orthomax[Z])
		
		cascade.matBias = matrix_multiply(matrix_multiply(cascade.matView, cascade.matProj), matbias)
		
		// D3D clips native depth to 0->1, keep the full caster range
		if (d3d)
			cascade.matProj = matrix_multiply(cascade.matProj, matdepth)
		
		// Set clip end
		cascade.clipEndDepth = zf * mp[@ 10] + mp[@ 14]
	}
}
