/// CppSeparate BoolType ds_list_valid(IntType)
/// ds_list_valid(id)
/// @arg id

function ds_list_valid(list)
{
	return (is_handle(list) && ds_exists(list, ds_type_list))
}
