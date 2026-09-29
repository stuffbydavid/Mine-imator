/// CppSeparate void shader_submit_vec3(IntType, RealType, RealType, RealType)
/// @arg index
/// @arg x
/// @arg y
/// @arg z

function shader_submit_vec3(index, xx, yy, zz)
{
	shader_set_uniform_f(index, xx, yy, zz)
}
