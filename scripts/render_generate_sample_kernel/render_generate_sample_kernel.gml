/// render_generate_sample_kernel(samples)
/// @arg samples

var arr;

for (var i = 0; i < argument0; i++)
{
	var xx, yy, zz, mag, scale;
	xx = random_range(-1, 1)
	yy = random_range(-1, 1)
	zz = random_range(0, 1)
	
	// Normalize
	mag = sqrt(xx * xx + yy * yy + zz * zz)
	xx /= mag
	yy /= mag
	zz /= mag
	
	// Exponentiate scale
	scale = i / argument0
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
