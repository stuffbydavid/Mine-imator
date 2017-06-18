/// file_rename_lib(oldname, newname)
/// @arg oldname
/// @arg newname

if (argument0 = "" || argument0 = argument1)
    return 0

return external_call(lib_file_rename, argument0, argument1)
