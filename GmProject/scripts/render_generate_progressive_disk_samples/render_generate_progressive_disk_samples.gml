/// render_generate_progressive_disk_samples(samples, seed)
/// @arg samples
/// @arg seed
/// @desc Generates progressively distributed disk samples

function render_generate_progressive_disk_samples(samples, seed)
{
	var kernel = array_create(samples * 2, 0)
	
	for (var i = 0; i < samples; i++)
	{
		var bestx = 0
		var besty = 0
		var bestdistance = -1
		
		// Pick the least crowded candidate
		for (var candidate = 0; candidate < 32; candidate++)
		{
			var sampleseed = seed * samples * 32 + i * 32 + candidate + 1
			var radius = sqrt(frac(abs(sin(sampleseed * 12.9898) * 43758.5453)))
			var angle = frac(abs(sin(sampleseed * 78.233) * 43758.5453)) * pi * 2
			var xx = cos(angle) * radius
			var yy = sin(angle) * radius
			var mindistance = 4
			
			for (var previous = 0; previous < i; previous++)
			{
				var dx = xx - kernel[previous * 2]
				var dy = yy - kernel[previous * 2 + 1]
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
