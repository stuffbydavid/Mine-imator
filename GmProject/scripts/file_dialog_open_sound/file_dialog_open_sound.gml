/// @desc Opens a dialog box for selecting a sound.

function file_dialog_open_sound()
{
	return file_dialog_open(text_get("file_dialog/open/sound") + " (*.mp3; *.wav; *.ogg; *.flac; *.wma; *.m4a)|*.mp3;*.wav;*.ogg;*.flac;*.wma;*.m4a;", "", "", text_get("file_dialog/open/sound_caption"))
}
