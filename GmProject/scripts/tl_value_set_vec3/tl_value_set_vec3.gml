/// tl_value_set_vec3(valueid, vec, [default])
function tl_value_set_vec3(valueid, vec, def = false)
{
	if (!def)
	{
		value[valueid + X] = vec[@X]
		value[valueid + Y] = vec[@Y]
		value[valueid + Z] = vec[@Z]
	}
	else
	{
		value_default[valueid + X] = vec[@X]
		value_default[valueid + Y] = vec[@Y]
		value_default[valueid + Z] = vec[@Z]
	}
}