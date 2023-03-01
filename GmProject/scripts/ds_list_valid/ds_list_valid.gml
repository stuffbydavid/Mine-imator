/// ds_list_valid(id)
/// @arg id

function ds_list_valid(list)
{
	return (is_real(list) && ds_exists(list, ds_type_list))
}
