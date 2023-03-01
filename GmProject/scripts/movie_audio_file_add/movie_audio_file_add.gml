/// movie_audio_file_add(filename)
/// @arg filename

function movie_audio_file_add(fn)
{
	return external_call(lib_movie_audio_file_add, fn)
}
