/// list_event_destroy()
function list_event_destroy()
{
	for (var i = 0; i < ds_list_size(item); i++)
		instance_destroy(item[|i])
	
	ds_list_destroy(item)
}
