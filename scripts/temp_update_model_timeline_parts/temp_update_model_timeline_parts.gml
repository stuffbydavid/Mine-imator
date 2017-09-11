/// temp_update_model_timeline_parts()
/// @desc Sets the model parts of affected timelines.

if (model_file = null)
	return 0

with (obj_timeline)
{
	if (temp != other.id)
		continue
		
	for (var mp = 0; mp < ds_list_size(temp.model_file.file_part_list); mp++)
	{
		if (temp.model_file.file_part_list[|mp].name = model_part_name)
		{
			model_part = temp.model_file.file_part_list[|mp]
			break
		}
	}
}