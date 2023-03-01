/// smoothstep(x)
/// @arg x

function smoothstep(xx)
{
	return (xx * xx * (3 - 2 * xx))
}