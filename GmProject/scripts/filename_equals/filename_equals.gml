/// @arg filename1
/// @arg filename2

function filename_equals(fn1, fn2)
{
	fn1 = string_replace_all(fn1, "\\", "/")
	fn2 = string_replace_all(fn2, "\\", "/")

	return fn1 = fn2
}
