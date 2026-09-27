/// render_generate_sample_kernel(samples)
/// @arg samples
/// @desc Generates a progressively distributed hemisphere sample kernel

function render_generate_sample_kernel(samples)
{
	var samples2d = render_generate_progressive_disk_samples(samples, 0)
	var arr = array_create(samples * 3, 0)
	
	for (var i = 0; i < samples; i++)
	{
		var xx = samples2d[i * 2]
		var yy = samples2d[i * 2 + 1]
		var zz = sqrt(max(1 - xx * xx - yy * yy, 0))
		
		// Exponentiate scale
		var scale = i / samples
		scale = lerp(0.1, 1.0, scale * scale)
		xx *= scale
		yy *= scale
		zz *= scale
		
		// Store in array
		arr[i * 3] = xx
		arr[i * 3 + 1] = yy
		arr[i * 3 + 2] = zz
	}
	
	return arr
}
