/// movie_start(filename, format)
/// @arg filename
/// @arg format

function movie_start(fn, format)
{
	return external_call(lib_movie_start, fn, format)
}
