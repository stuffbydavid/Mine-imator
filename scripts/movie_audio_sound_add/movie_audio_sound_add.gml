/// movie_audio_sound_add(file, play, volume, start, end)
/// @arg file
/// @arg play
/// @arg volume
/// @arg start
/// @arg end

function movie_audio_sound_add(file, play, volume, start, ed)
{
	return external_call(lib_movie_audio_sound_add, file, play, volume, start, ed)
}
