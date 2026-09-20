/// tl_value_copy_vec3(valueid, dest, src)

function tl_value_copy_vec3(valueid, dest, src)
{
	dest[@valueid + X] = src[@valueid + X]
	dest[@valueid + Y] = src[@valueid + Y]
	dest[@valueid + Z] = src[@valueid + Z]
}