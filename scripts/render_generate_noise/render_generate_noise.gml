/// render_generate_noise(width, height, [surface])
/// @arg width
/// @arg height
/// @arg [surface]

function render_generate_noise()
{
	var w, h, surf;
	w = argument[0]
	h = argument[1]
	surf = null
	
	if (argument_count > 2)
		surf = argument[2]
	
	if (!surface_exists(surf))
		surf = surface_create(w, h)
	
	surface_set_target(surf)
	{
		draw_clear(c_white)
		
		for (var xx = 0; xx < w; xx++)
		{
			for (var yy = 0; yy < h; yy++)
			{
				var r, g, b, mag;
				r = random(1)
				g = random(1)
				b = random(1)//0.5
				
				mag = sqrt(r * r + g * g + b * b)
				r /= mag
				g /= mag
				b /= mag
				
				draw_point_color(xx, yy, make_color_rgb(r * 255, g * 255, b * 255)) 
			}
		}
	}
	surface_reset_target()
	
	return surf
}
