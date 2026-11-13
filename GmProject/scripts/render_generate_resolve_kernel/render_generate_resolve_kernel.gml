/// @desc Generates a square resolve kernel with the center and closest samples first.
/// A size of 1 creates 3x3, 2 creates 5x5, and so on.

function render_generate_resolve_kernel(size = 0)
{
	size = max(0, floor(size))
	
	var width, kernel, index;
	width = size * 2 + 1
	kernel = array_create(width * width * 2, 0)
	index = 0
	
	for (var radius = 0; radius <= size; radius++)
	{
		for (var yy = -radius; yy <= radius; yy++)
		{
			for (var xx = -radius; xx <= radius; xx++)
			{
				if (max(abs(xx), abs(yy)) != radius)
					continue
				
				kernel[index++] = xx
				kernel[index++] = yy
			}
		}
	}
	
	return kernel
}
