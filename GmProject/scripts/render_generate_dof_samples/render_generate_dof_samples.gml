/// @desc Generates progressive disk samples.

function render_generate_dof_samples(blades, rotation, ratio, stretch)
{
	var pixelvariation, samples, goldenangle, frameangle, c, s;
	pixelvariation = (renderer_current = e_renderer.REALISTIC || app.project_render_dof_realistic_blur)
	samples = clamp(round(app.project_render_dof_quality), 8, 64)
	goldenangle = pi * (3 - sqrt(5))
	frameangle = 0
	
	c = cos(-degtorad(rotation))
	s = sin(-degtorad(rotation))
	
	if (renderer_current = e_renderer.REALISTIC)
		frameangle = frac(render_sample_current * .61803399) * pi * 2
	
	render_dof_samples = array_create(samples * 2, 0)
	render_dof_weight_samples = array_create(samples, 0)
	render_dof_area_samples = array_create(samples, 1)
	render_dof_sample_amount = samples
	
	for (var i = 0; i < samples; i++)
	{
		var radius, angle;
		radius = sqrt((i + .5) / samples)
		angle = i * goldenangle + frameangle

		render_dof_weight_samples[i] = radius
		
		if (pixelvariation)
		{
			if (blades > 2)
			{
				// The shader rotates and shapes polygon taps independently at each pixel
				render_dof_samples[i * 2] = radius
				render_dof_samples[i * 2 + 1] = angle
			}
			else
			{
				render_dof_samples[i * 2] = cos(angle) * radius
				render_dof_samples[i * 2 + 1] = sin(angle) * radius
			}
		}
		else
		{
			var edge, xx, yy;
			edge = 1
			
			if (blades > 2)
			{
				var step, firstnormal, sectorangle, localangle, polygonedge;
				step = pi * 2 / blades
				firstnormal = pi * 1.5 + step * .5
				sectorangle = angle - firstnormal + step * .5
				localangle = sectorangle - floor(sectorangle / step) * step - step * .5
				polygonedge = cos(step * .5) / cos(localangle)
				
				// Bow each blade edge slightly toward a circular aperture
				edge = lerp(polygonedge, 1, render_dof_blade_rounding)
			}
			
			xx = cos(angle) * radius * edge
			yy = sin(angle) * radius * edge
			xx *= 1 - max(stretch, 0)
			yy *= 1 + min(stretch, 0)
			var rotatedx = xx * c - yy * s;
			var rotatedy = xx * s + yy * c;
			render_dof_samples[i * 2] = rotatedx * (1 - max(ratio, 0))
			render_dof_samples[i * 2 + 1] = rotatedy * (1 + min(ratio, 0))
			render_dof_area_samples[i] = edge * edge
		}
	}
}
