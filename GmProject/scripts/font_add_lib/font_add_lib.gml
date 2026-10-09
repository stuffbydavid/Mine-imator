/// @arg filename
/// @arg size
/// @arg bold
/// @arg italic
/// @arg [antialiasing]

function font_add_lib(fn, size, bold, italic, aa = true)
{
	var tmpfile = file_directory_get() + "tmp.ttf";
	
	file_copy_lib(fn, tmpfile)
	
	if (file_exists_lib(tmpfile))
	{
		font_add_enable_aa(aa)
		var fnt = font_add(tmpfile, size, bold, italic, 32, 1024);
		font_add_enable_aa(true)
		
		if (font_exists(fnt))
			return fnt
	}
	
	return null
}
