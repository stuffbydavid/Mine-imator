/// @desc Rotates progressive disk samples.

function render_rotate_progressive_disk_samples(samples, angle)
{
	var rotated, anglecos, anglesin;
	rotated = array_create(array_length(samples), 0)
	anglecos = cos(angle)
	anglesin = sin(angle)
	
	for (var i = 0; i < array_length(samples); i += 2)
	{
		var xx, yy;
		xx = samples[i]
		yy = samples[i + 1]
		rotated[i] = xx * anglecos - yy * anglesin
		rotated[i + 1] = xx * anglesin + yy * anglecos
	}
	
	return rotated
}
