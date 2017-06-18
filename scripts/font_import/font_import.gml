/// font_import(filename, size, bold, italic)
/// @arg filename
/// @arg size
/// @arg bold
/// @arg italic

var tmpfile = file_directory + "tmp.ttf"

file_delete_lib(tmpfile)
file_copy_lib(argument0, tmpfile)

if (file_exists_lib(tmpfile))
{
    var fnt = font_add(tmpfile, argument1, argument2, argument3, 32, 255);
    if (font_exists(fnt))
        return fnt
}

return null
