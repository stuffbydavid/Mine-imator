/// model_part_event_destroy()

function model_part_event_destroy()
{
	if (shape_list != null)
	{
		for (var s = 0; s < ds_list_size(shape_list); s++)
			with (shape_list[|s])
				instance_destroy()
		
		ds_list_destroy(shape_list)
	}
	
	if (part_list != null)
	{
		for (var p = 0; p < ds_list_size(part_list); p++)
			with (part_list[|p])
				instance_destroy()
		
		ds_list_destroy(part_list)
	}
}
