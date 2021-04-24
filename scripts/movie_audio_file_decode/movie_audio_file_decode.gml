/// movie_audio_file_decode(source, destination)
/// @arg source
/// @arg destination

function movie_audio_file_decode(src, dest)
{
	return external_call(lib_movie_audio_file_decode, src, dest)
}
