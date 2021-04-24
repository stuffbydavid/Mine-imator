/// angle_difference_fix(angle1, angle2)
/// @arg angle1
/// @arg angle2

function angle_difference_fix(angle1, angle2)
{
	return ((((angle1 - angle2) mod 360) + 540) mod 360) - 180;
}
