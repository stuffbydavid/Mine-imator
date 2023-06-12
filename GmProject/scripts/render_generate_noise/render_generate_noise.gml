/// render_generate_noise(width, height, [surface, [normal]])
/// @arg width
/// @arg height
/// @arg [surface
/// @arg [normal]]

function render_generate_noise(w, h, surf = null, normal = false)
{
	if (!surface_exists(surf))
		surf = surface_create(w, h)
	
	surface_set_target(surf)
	{
		draw_clear(c_white)
		
		for (var xx = 0; xx <= w; xx++)
		{
			for (var yy = 0; yy <= h; yy++)
			{
				var r, g, b, mag;
				r = random(1)
				g = random(1)
				b = random(normal ? 0.5 : 1)
				
				if (normal)
				{
					mag = sqrt(r * r + g * g + b * b)
					r /= mag
					g /= mag
					b /= mag
				}
				
				draw_point_color(xx, yy, make_color_rgb(r * 255, g * 255, b * 255)) 
			}
		}
	}
	surface_reset_target()
	
	return surf
}
