/// model_shape_get_bend(bend, weight)
/// @arg bend
/// @arg weight

var bend, weight;
bend = argument0
weight = argument1

for (var i = X; i <= Z; i++)
	bend[X + i] = clamp(bend[X + i], bend_direction_min[i], bend_direction_max[i])

return vec3(bend[X] * ease("easeinoutquint", weight), bend[Y] * ease("easeinoutquint", weight), bend[Z] * weight)