/// point_lerp(point1, point2, amount)
/// @arg point1
/// @arg point2
/// @arg amount

function point_lerp(pnt1, pnt2, amount)
{
	var np = [];
	
	for (var i = 0; i < array_length(pnt1); i++)
		np[i] = lerp(pnt1[i], pnt2[i], amount)
	
	return np
}