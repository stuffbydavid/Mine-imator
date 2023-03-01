/// render_generate_dof_samples(blades, rotation, ratio)
/// @arg blades
/// @arg rotation
/// @arg ratio

function render_generate_dof_samples(blades, rotation, ratio)
{
	var rings, samples, rotoff;
	rings = 7
	samples = 3
	rotoff = (pi*2) / (360/270)
	
	// Clear previous data
	render_dof_samples = 0
	render_dof_weight_samples = 0
	render_dof_sample_amount = 0
	
	var disnoise, rotnoise;
	
	if (render_sample_current = 0 || render_quality != e_view_mode.RENDER)
	{
		disnoise = 0
		rotnoise = 0
	}
	else
	{
		disnoise = random(1)
		rotnoise = random_range(0, pi * 2)
	}
	
	// Calculate all possible sample positions
	for (var i = 0; i < rings; i++)
	{
		var ringsamples = i * samples;
		var anglestep = (pi * 2) / ringsamples;
		var dis = frac((i / rings) + disnoise);
		
		for (var j = 0; j < ringsamples; j++)
		{
			var offset = point2D_mul(point2D(cos((j * anglestep) + rotnoise), sin((j * anglestep) + rotnoise)), dis);
			
			render_dof_samples[render_dof_sample_amount * 2] = offset[X]
			render_dof_samples[render_dof_sample_amount * 2 + 1] = offset[Y]
			render_dof_weight_samples[render_dof_sample_amount] = dis
			render_dof_sample_amount++
		}
	}
	
	// Rotate/mask samples
	for (var i = 0; i < render_dof_sample_amount; i++)
	{
		var samplepos;
		samplepos = point2D(render_dof_samples[i * 2], render_dof_samples[i * 2 + 1])
		
		// Mask if there's enough blades
		if (blades > 2)
		{
			var scale, inblades, anglestep, prevcornerpos, cornerpos;
			scale = 1
			inblades = false
			anglestep = ((pi*2)/blades) * (blades - 1)
			prevcornerpos = point2D(cos(anglestep + rotoff) * scale, sin(anglestep + rotoff) * scale)
			
			// Every two corners is a corner in a triangle, third being the middle of polygon
			for (var j = 0; j < blades; j++)
			{
				var anglestep = ((pi*2)/blades) * j;
				cornerpos = point2D(cos(anglestep + rotoff) * scale, sin(anglestep + rotoff) * scale)
				
				if (point_in_triangle(samplepos[X], samplepos[Y], 0, 0, prevcornerpos[X], prevcornerpos[Y], cornerpos[X], cornerpos[Y]))
				{
					var midpoint;
					midpoint = point2D(lerp(prevcornerpos[X], cornerpos[X], 0.5), lerp(prevcornerpos[Y], cornerpos[Y], 0.5))
					
					render_dof_weight_samples[i] = clamp(vec2_dot(samplepos, midpoint) / vec2_dot(midpoint, midpoint), 0, 1)
					inblades = true
				}
				
				prevcornerpos = cornerpos
			}
			
			if (!inblades)
				render_dof_weight_samples[i] = 0
		}
		
		// Scale Y with ratio
		samplepos[Y] *= (1 - ratio)
		
		// Rotate
		samplepos = uv_rotate(samplepos, -rotation, point2D(0, 0))
		render_dof_samples[i * 2] = samplepos[X]
		render_dof_samples[i * 2 + 1] = samplepos[Y]
	}
}
