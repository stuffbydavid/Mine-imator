/// interpolate(function, d, x1, x2)
/// @arg function
/// @arg d
/// @arg x1
/// @arg x2

function interpolate(func, d, x1, x2)
{
	return x1 + ease(func, d) * (x2 - x1)
}
