/// vec4(x, y, z, w)
/// @arg x
/// @arg y
/// @arg z
/// @arg w

gml_pragma("forceinline")

var vec;

if (argument_count = 1)
{
	vec[X] = argument[0]
	vec[Y] = argument[0]
	vec[Z] = argument[0]
	vec[W] = argument[0]
}
else
{
	vec[X] = argument[0]
	vec[Y] = argument[1]
	vec[Z] = argument[2]
	vec[W] = argument[3]
}

return vec
