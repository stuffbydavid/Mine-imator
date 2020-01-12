/// model_shape_get_bend(bend, weight)
/// @arg bend
/// @arg weight

var bend, weight;
bend = argument0
weight = argument1

return vec3(bend[X] * ease("easeinoutquint", weight), bend[Y] * ease("easeinoutquint", weight), bend[Z] * weight)