/// @desc Generates progressively distributed disk samples.

function render_generate_progressive_disk_samples(samples, seed)
{
	var kernel = array_create(samples * 2, 0);
	
	for (var i = 0; i < samples; i++)
	{
		var bestx, besty, bestdistance;
		bestx = 0
		besty = 0
		bestdistance = -1
		
		// Pick the least crowded candidate
		for (var candidate = 0; candidate < 32; candidate++)
		{
			var sampleseed, radius, angle, xx, yy, mindistance; 
			sampleseed = seed * samples * 32 + i * 32 + candidate + 1
			radius = sqrt(frac(abs(sin(sampleseed * 12.9898) * 43758.5453)))
			angle = frac(abs(sin(sampleseed * 78.233) * 43758.5453)) * pi * 2
			xx = cos(angle) * radius
			yy = sin(angle) * radius
			mindistance = 4
			
			for (var previous = 0; previous < i; previous++)
			{
				var dx, dy;
				dx = xx - kernel[previous * 2]
				dy = yy - kernel[previous * 2 + 1]
				mindistance = min(mindistance, dx * dx + dy * dy)
			}
			
			if (mindistance > bestdistance)
			{
				bestdistance = mindistance
				bestx = xx
				besty = yy
			}
		}
		
		kernel[i * 2] = bestx
		kernel[i * 2 + 1] = besty
	}
	
	return kernel
}
