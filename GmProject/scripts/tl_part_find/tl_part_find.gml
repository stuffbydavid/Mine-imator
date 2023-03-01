/// tl_part_find(name)
/// @arg name

function tl_part_find(name)
{
	if (part_list != null)
		for (var p = 0; p < ds_list_size(part_list); p++)
			if (part_list[|p].model_part_name = name)
				return part_list[|p]
	
	return null
}
