/// temp_update_model_timeline_parts()
/// @desc Sets the model parts of affected timelines.

with (obj_timeline)
	if (temp = other.id && part_list != null)
		for (var i = 0; i < ds_list_size(part_list); i++)
			with (part_list[|i])
				model_part = temp.model_file.file_part_list[|i]