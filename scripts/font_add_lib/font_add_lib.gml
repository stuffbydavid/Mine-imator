/// font_add_lib(filename, size, bold, italic, [aa])
/// @arg filename
/// @arg size
/// @arg bold
/// @arg italic
/// @arg [aa]

var tmpfile, aa;
tmpfile = file_directory + "tmp.ttf"
aa = true

if (argument_count > 4)
	aa = argument[4]

file_copy_lib(argument[0], tmpfile)

if (file_exists_lib(tmpfile))
{
	font_add_enable_aa(aa)
	var fnt = font_add(tmpfile, argument[1], argument[2], argument[3], 32, 1024);
	font_add_enable_aa(true)
	
	if (font_exists(fnt))
		return fnt
}

return null
