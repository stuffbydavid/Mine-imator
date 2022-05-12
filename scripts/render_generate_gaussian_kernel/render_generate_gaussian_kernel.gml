/// render_generate_gaussian_kernel(samples)
/// @desc Generates guassian kernel using Pascal's triangle (use odd numbers)
/// Every two values in the kernel is a pair, a guassian weight and a unit offset.

function render_generate_gaussian_kernel(samples)
{
	var prevrow, currentrow, kernel, sum, largestnum, largestindex;
	prevrow = array_create(samples, 0)
	currentrow = array_create(samples, 0)
	largestindex = 0
	largestnum = 0
	
	prevrow[0] = 1
	prevrow[1] = 1
	currentrow[0] = 1
	currentrow[1] = 1
	
	var i = 3;
	for (; i <= samples; i++)
	{
		sum = 0
		
		// Copy previous row into new
		for (var j = 1; j < i; j++)
			currentrow[j] = prevrow[j - 1] + prevrow[j]
		
		for (var j = 1; j < i; j++)
		{
			prevrow[j] = currentrow[j]
			sum += currentrow[j]
		}
	}
	
	// Normalize
	for (var p = 0; p < 5; p++)
	{
		i = 0
		for (; i < samples; i++)
			currentrow[i] /= sum
	
		i = 0
		sum = 0
		for (; i < samples; i++)
			sum += currentrow[i]
	}
	
	// Put largest number in front for middle sample
	i = 0
	for (; i < samples; i++)
	{
		if (currentrow[i] > largestnum)
		{
			largestindex = i
			largestnum = currentrow[i]
		}
	}
	
	prevrow[0] = largestnum
	array_copy(prevrow, 1, currentrow, 0, largestindex)
	array_copy(prevrow, largestindex + 1, currentrow, largestindex + 1, samples - largestindex)
	
	// Add linear offset values
	kernel[0] = prevrow[0]
	kernel[1] = 0
	
	i = 1
	for (; i < samples; i++)
	{
		kernel[i * 2] = prevrow[i]
		
		var rad = ((i - 1) - (samples - 1)) + ((samples - 1)/2);
		
		if (rad >= 0)
			rad++
		
		rad /= (samples-1)
		
		kernel[(i * 2) + 1] = rad * 2
	}
	
	return kernel
}