/// CppSeparate void shader_submit_vec4(IntType, RealType, RealType, RealType, RealType)
function shader_submit_vec4(index, xx, yy, zz, ww)
{
	shader_set_uniform_f(index, xx, yy, zz, ww)
}
