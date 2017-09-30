/// state_vars_add(destvars, srcvars)
/// @arg dest
/// @arg src
/// @desc Combines two arrays of name-value pairs.

var dest, src, srclen;
dest = argument0
src = argument1
srclen = array_length_1d(src)

for (var i = 0; i < srclen; i += 2)
{
	// Find name in the destination array
	var j;
	for (j = 0; j < array_length_1d(dest); j += 2)
		if (dest[@ j] = src[@ j])
			break
			
	// Overwrite/Add value
	dest[@ j] = src[@ i]
	dest[@ j + 1] = src[@ i + 1]
}