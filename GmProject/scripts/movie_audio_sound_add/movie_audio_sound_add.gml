/// @arg file
/// @arg play
/// @arg volume
/// @arg pitch
/// @arg start
/// @arg end

function movie_audio_sound_add(file, play, volume, pitch, soundstart, soundend)
{
	return external_call(lib_movie_audio_sound_add, file, play, volume, pitch, soundstart, soundend)
}
