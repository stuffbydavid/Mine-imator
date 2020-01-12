/// model_shape_get_bend_scale(bendstart, bendend, weight, start, bendpos, bend)
/// @arg bendstart
/// @arg bendend
/// @arg weight
/// @arg start
/// @arg bendpos
/// @arg bend
/// @desc Returns a scale for blocky bending to adjust pinching.

var bendstart, bendend, weight, start, bendpos, bend;
var bendscale;
bendstart = argument0
bendend = argument1
weight = argument2
start = argument3
bendpos = argument4
bend = argument5

if (bendpos > bendstart && bendpos < bendend)
{
	if (weight <= 0.5)
		bendscale = vec3(weight * 2)
	else
		bendscale = vec3((1 - weight) * 2)
	
	var bendaxis, bendang;
	if (vec3_equals(bend_axis, vec3(true, false, false)))
		bendaxis = X
	else if (vec3_equals(bend_axis, vec3(false, true, false)))
		bendaxis = Y
	
	bendang = abs(bend[bendaxis])
	
	if (bendang > 90)
		bendang -= (bendang - 90) * 2
	
	var bendperc = percent(bendang, 0, 90);
	bendperc = clamp(bendperc, 0, 1)
	bendscale = vec3_mul(bendscale, bendperc)
	
	for (var i = X; i <= Z; i++)
		bendscale[i] = ease("easeincubic", bendscale[i])
	
	bendscale = vec3_div(bendscale, 2.5)
	
	bendscale[bendaxis] = 0
	
	return bendscale
}
else
	return vec3(0)