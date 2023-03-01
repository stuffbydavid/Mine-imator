/// movie_set(width, height, bitrate, framerate, audio)
/// @arg width
/// @arg height
/// @arg bitrate
/// @arg framerate
/// @arg audio

function movie_set(width, height, bitrate, framerate, audio)
{
	return external_call(lib_movie_set, width, height, bitrate, framerate, audio)
}
