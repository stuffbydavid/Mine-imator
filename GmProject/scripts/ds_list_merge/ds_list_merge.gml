/// ds_list_merge(id, source)
/// @arg id
/// @arg source

function ds_list_merge(list, src)
{
	for (var i = 0; i < ds_list_size(src); i++)
		ds_list_add(list, src[|i])
}
