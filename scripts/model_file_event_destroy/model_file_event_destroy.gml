/// model_file_event_destroy()

if (part_list != null)
{
	for (var p = 0; p < ds_list_size(part_list); p++)
		with (part_list[|p])
			instance_destroy()
		
	ds_list_destroy(part_list)
}