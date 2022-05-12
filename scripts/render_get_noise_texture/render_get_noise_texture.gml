/// render_get_noise_texture(index)
/// @arg index

function render_get_noise_texture(index)
{
	if (array_length(render_sample_noise_texture_array) < (index + 1) || !surface_exists(render_sample_noise_texture_array[index]))
	{
		var surf, xoff, yoff;
		surf = surface_create(render_sample_noise_size, render_sample_noise_size)
		
		randomize()
		xoff = irandom_range(0, render_sample_noise_size)
		randomize()
		yoff = irandom_range(0, render_sample_noise_size)
		
		surface_set_target(surf)
		{
			draw_sprite(spr_blue_noise, 0, xoff - render_sample_noise_size, yoff - render_sample_noise_size)
			draw_sprite(spr_blue_noise, 0, xoff - render_sample_noise_size, yoff)
			draw_sprite(spr_blue_noise, 0, xoff, yoff - render_sample_noise_size)
			draw_sprite(spr_blue_noise, 0, xoff, yoff)
		}
		surface_reset_target()
		
		render_sample_noise_texture_array[index] = surf
		
		//render_sample_noise_texture_array[index] = render_generate_noise(render_sample_noise_size, render_sample_noise_size, null)
	}
		
	
	return render_sample_noise_texture_array[index]
}