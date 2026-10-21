function movie_set(width, height, bitrate, framerate, includeaudio)
{
	return external_call(lib_movie_set, width, height, bitrate, framerate, includeaudio)
}
