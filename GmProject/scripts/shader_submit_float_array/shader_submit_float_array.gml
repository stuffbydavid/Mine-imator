/// CppSeparate void shader_submit_float_array(IntType, VarType)
/// @arg index
/// @arg array

function shader_submit_float_array(index, arr)
{
	shader_set_uniform_f_array(index, arr)
}
