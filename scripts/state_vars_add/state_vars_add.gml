/// state_vars_add(destvars, srcvars)
/// @arg dest
/// @arg src
/// @desc Combines two arrays of name-value pairs.

function state_vars_add(dest, src)
{
	var srclen = array_length(src);
	
	for (var i = 0; i < srclen; i += 2)
	{
		// Find name in the destination array
		var j;
		for (j = 0; j < array_length(dest); j += 2)
			if (dest[@ j] = src[@ i])
				break
		
		// Overwrite/Add value
		dest[@ j] = src[@ i]
		dest[@ j + 1] = src[@ i + 1]
	}
}
