/// tl_value_get_vec3(valueid, [default])
function tl_value_get_vec3(valueid, def = false)
{
	if (!def)
		return vec3(
			value[@valueid + X],
			value[@valueid + Y],
			value[@valueid + Z]
		)
	else
		return vec3(
			value_default[@valueid + X],
			value_default[@valueid + Y],
			value_default[@valueid + Z]
		)
}