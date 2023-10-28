/// model_shape_get_bend_scale(bendstart, bendend, weight, start, bendpos, bend)
/// @arg bendstart
/// @arg bendend
/// @arg weight
/// @arg start
/// @arg bendpos
/// @arg bend
/// @desc Returns a scale for blocky bending to adjust pinching.

function model_shape_get_bend_scale(bendstart, bendend, weight, start, bendpos, bend)
{
	if (bendpos > bendstart && bendpos < bendend)
	{
		var bendscale;
		
		if (weight <= 0.5)
			bendscale = vec3(weight * 2)
		else
			bendscale = vec3((1 - weight) * 2)
		
		var bendaxis, bendang;
		if (vec3_equals(bend_axis, vec3(true, false, false)))
			bendaxis = X
		else if (vec3_equals(bend_axis, vec3(false, true, false)))
			bendaxis = Y
		else if (vec3_equals(bend_axis, vec3(false, false, true)))
			bendaxis = Z
		
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
}
