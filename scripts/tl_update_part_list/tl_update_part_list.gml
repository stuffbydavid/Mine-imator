/// tl_update_part_list(part, parent)
/// @arg part
/// @arg parent
/// @desc Sets the model parts and hierarchy of the timelines.

var part, par;
part = argument0
par = argument1

for (var mp = 0; mp < ds_list_size(part.part_list); mp++)
{
	var mpart = part.part_list[|mp];
	
	// Find timeline with name
	for (var p = 0; p < ds_list_size(part_list); p++)
	{
		var tl = part_list[|p];
		if (tl.model_part_name = mpart.name)
		{
			with (tl)
			{
				model_part = mpart
				tl_set_parent(par)
				tl_update_value_types()
				tl_update_type_name()
				tl_update_display_name()
			}
			
			// Recurse for this part
			if (mpart.part_list != null)
				tl_update_part_list(mpart, tl)
			break	
		}
	}
}