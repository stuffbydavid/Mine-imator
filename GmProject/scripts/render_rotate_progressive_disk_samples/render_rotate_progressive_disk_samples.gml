/// render_rotate_progressive_disk_samples(samples, angle)
/// @arg samples
/// @arg angle
/// @desc Rotates progressive disk samples

function render_rotate_progressive_disk_samples(samples, angle)
{
	var rotated = array_create(array_length(samples), 0)
	var anglecos = cos(angle)
	var anglesin = sin(angle)
	
	for (var i = 0; i < array_length(samples); i += 2)
	{
		var xx = samples[i]
		var yy = samples[i + 1]
		rotated[i] = xx * anglecos - yy * anglesin
		rotated[i + 1] = xx * anglesin + yy * anglecos
	}
	
	return rotated
}
