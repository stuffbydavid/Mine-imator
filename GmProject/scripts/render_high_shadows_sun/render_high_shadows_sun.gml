/// @desc Prepares the sunlight cascades for receiver lighting.

function render_high_shadows_sun()
{
	var angle, sunangularradius, refangularradius;
	angle = vec3_normalize(app.env_sun_direction)
	sunangularradius = tan(degtorad(min(env_sunlight_angle, 179)) * .5) * project_render_shadows_blur_size
	refangularradius = tan(degtorad(.526) * .5)
	
	render_sun_shadow_scale = (sunangularradius / refangularradius) * .5

	// Jitter sun direction
	if (project_render_shadows_jittered && render_sample_current > 1)
	{
		var ref, tangent, bitangent, diskangle, diskradius, diskoffset;
		ref = abs(angle[Z]) < .999 ? vec3(0, 0, 1) : vec3(0, 1, 0)
		tangent = vec3_normalize(vec3_cross(ref, angle))
		bitangent = vec3_cross(angle, tangent)
		diskangle = random(pi * 2)
		diskradius = sunangularradius * sqrt(random(1))
		diskoffset = vec3_add(vec3_mul(tangent, cos(diskangle) * diskradius), vec3_mul(bitangent, sin(diskangle) * diskradius))
		angle = vec3_normalize(vec3_add(angle, diskoffset))
	}

	// Depth
	cam_far = cam_far_prev
	
	aa_matrix = MAT_IDENTITY
	
	render_alpha_hash = render_alpha_hash_shadows
	render_alpha_hash_force = true

	render_update_cascades(angle)

	for (var i = 0; i < render_cascades_count; i++)
	{
		var sunkey = "sun" + string(i);
		if (render_shadow_cache_enabled)
			render_surface_sun_buffer[i] = render_shadow_cache_surface(sunkey, project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size, is_cpp())
		else
			render_surface_sun_buffer[i] = surface_require(render_surface_sun_buffer[i], project_render_shadows_sun_buffer_size, project_render_shadows_sun_buffer_size, true, surface_r32float, is_cpp())

		if (render_shadow_cache_enabled && ds_map_exists(render_shadow_cache_ready, sunkey))
		{
			render_world_start_sun(i)
			render_world_done()
			
			continue
		}
		
		surface_set_target(render_surface_sun_buffer[i])
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)

			draw_clear(c_white)
			render_world_start_sun(i)
			render_world(e_render_mode.HIGH_LIGHT_SUN_DEPTH)
			render_world_done()

			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		if (render_shadow_cache_enabled)
			render_shadow_cache_ready[?sunkey] = true
	}

	aa_matrix = aa_jitter_matrix
	
	render_alpha_hash = render_alpha_hash_allowed && app.project_render_alpha_mode
	render_alpha_hash_force = false
}
