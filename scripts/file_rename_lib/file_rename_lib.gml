/// file_rename_lib(oldname, newname)
/// @arg oldname
/// @arg newname

function file_rename_lib(oldname, newname)
{
	if (oldname = "" || oldname = newname)
		return 0
	
	return external_call(lib_file_rename, oldname, newname)
}
