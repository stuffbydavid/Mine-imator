/// CppSeparate void shader_submit_vec2(IntType, RealType, RealType)
/// @arg index
/// @arg x
/// @arg y

function shader_submit_vec2(index, xx, yy)
{
	shader_set_uniform_f(index, xx, yy)
}
