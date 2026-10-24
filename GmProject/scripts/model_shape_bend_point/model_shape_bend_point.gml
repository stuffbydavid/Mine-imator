/// @desc Stores the fixed segment weight alongside a rotated rest position
function model_shape_bend_point(pos, segpos, bendstart, bendsize, invangle, start = false)
{
	var weight;
	if (segpos < bendstart)
		weight = 0
	else if (segpos >= bendstart + bendsize)
		weight = 1
	else
		weight = (segpos - bendstart) / bendsize
	if (invangle)
		weight = 1 - weight
	return vec4(pos[X], pos[Y], pos[Z], start ? -1 - weight : weight)
}
