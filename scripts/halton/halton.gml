/// halton(index, x)
/// @arg index
/// @arg x

function halton(i, xx)
{
	var f, r;
	f = 1.0
	r = 0.0
	
	while (i > 0)
	{
		f /= xx
		r = r + f * (i mod xx)
		i = floor(i/xx)
	}
	
	return r
}