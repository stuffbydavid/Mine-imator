/// movie_audio_sound_add(file, play, volume, pitch, start, end)
/// @arg file
/// @arg play
/// @arg volume
/// @arg pitch
/// @arg start
/// @arg end

function movie_audio_sound_add(file, play, volume, pitch, start, ed)
{
	return external_call(lib_movie_audio_sound_add, file, play, volume, pitch, start, ed)
}
