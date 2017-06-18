/// directory_exists_lib(directory)
/// @arg directory

if (argument0 = "")
    return 0

return external_call(lib_directory_exists, argument0)
