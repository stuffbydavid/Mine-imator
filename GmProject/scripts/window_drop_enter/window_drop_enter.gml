/// @desc Returns whether an array of filenames are accepted to be dropped on the window.

function window_drop_enter(files)
{
	if (window_busy != "")
		return false
	
	if (array_length(files) > 1) // TODO multifile support?
		return false
	
	return string_contains(asset_exts, "*" + filename_ext(files[0]) + ";")
}
