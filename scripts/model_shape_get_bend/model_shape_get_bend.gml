/// model_shape_get_bend(bend, weight)
/// @arg bend
/// @arg weight

function model_shape_get_bend(bend, weight)
{
	return vec3(bend[X] * ease("easeinoutquint", weight), bend[Y] * ease("easeinoutquint", weight), bend[Z] * weight)
}
