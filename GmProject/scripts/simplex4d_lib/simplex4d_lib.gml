/// @arg x
/// @arg y
/// @arg z
/// @arg w

function simplex4d_lib(xx, yy, zz, ww)
{
	return external_call(lib_math_simplex4d, xx, yy, zz, ww)
}
