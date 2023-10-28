/// font_add_lib(filename, size, bold, italic, [aa])
/// @arg filename
/// @arg size
/// @arg bold
/// @arg italic
/// @arg [aa]

function font_add_lib(fname, size, bold, italic, aa = true)
{
	var tmpfile = file_directory + "tmp.ttf"
	
	file_copy_lib(fname, tmpfile)
	
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
