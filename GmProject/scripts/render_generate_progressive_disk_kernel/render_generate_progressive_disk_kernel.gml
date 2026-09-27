/// render_generate_progressive_disk_kernel(samples, seed)
/// @arg samples
/// @arg seed
/// @desc Generates progressively distributed disk samples with radial weights and a center sample

function render_generate_progressive_disk_kernel(samples, seed)
{
	var samples2d = render_generate_progressive_disk_samples(samples, seed)
	var kernel = array_create((samples + 1) * 3, 0)
	kernel[2] = 1

	for (var i = 0; i < samples; i++)
	{
		var xx = samples2d[i * 2]
		var yy = samples2d[i * 2 + 1]
		var weight = max(1 - xx * xx - yy * yy, .05)
		weight *= weight
		kernel[(i + 1) * 3] = xx
		kernel[(i + 1) * 3 + 1] = yy
		kernel[(i + 1) * 3 + 2] = weight
	}

	return kernel
}
