/// render_high_shadows_shadowless()

function render_high_shadows_shadowless()
{
	if (ds_list_size(render_shadowless_point_list) > 0)
	{
		var resultsurftemp, lights, batches, specresultsurftemp;
		lights = ds_list_size(render_shadowless_point_list)
		batches = 0
			
		while (lights > 0)
		{
			for (var l = 0; l < 31; l++)
			{
				if (lights = 0)
					continue
					
				var light = render_shadowless_point_list[| l + (batches * 31)];
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 0] = light.world_pos[X]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 1] = light.world_pos[Y]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 2] = light.world_pos[Z]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 3] = light.value[e_value.LIGHT_RANGE]
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 4] = (color_get_red(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 5] = (color_get_green(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 6] = (color_get_blue(light.value[e_value.LIGHT_COLOR]) / 255)
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 7] = light.value[e_value.LIGHT_FADE_SIZE]
					
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 8] = light.value[e_value.LIGHT_STRENGTH]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 9] = light.value[e_value.LIGHT_SPECULAR_STRENGTH]
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 10] = 1
				render_shadowless_point_data[render_shadowless_point_amount * 12 + 11] = 1
				render_shadowless_point_amount++
				lights--
			}
			
			// Render lights
			resultsurftemp = render_surface_hdr[0]
			specresultsurftemp = render_surface_hdr[1]
			
			surface_set_target_ext(0, resultsurftemp)
			surface_set_target_ext(1, specresultsurftemp)
			{
				draw_clear(c_black)
				render_world_start()
				render_world(e_render_mode.HIGH_LIGHT_POINT_SHADOWLESS)
				render_world_done()
			}
			surface_reset_target()
			
			// Add to final shadow surface
			surface_set_target(render_surface_shadows)
			{
				gpu_set_blendmode(bm_add)
				draw_surface_exists(resultsurftemp, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
				
			surface_set_target(render_surface_specular)
			{
				gpu_set_blendmode(bm_add)
				draw_surface_exists(specresultsurftemp, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
				
			batches++
			render_shadowless_point_amount = 0
		}
			
		ds_list_clear(render_shadowless_point_list)
	}
}
