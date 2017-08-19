/// new_tl_model_file_parts(root, modelfile)
/// @arg root
/// @arg modelfile

var root, modelfile;
root = argument0
modelfile = argument1

for (var p = 0; p < ds_list_size(modelfile.part_list); p++)
{
	var part = modelfile.part_list[|p];
	with (new(obj_timeline))
	{
		type = "bodypart"
		temp = other.temp
		model_part = part
		model_part_name = part.name
		part_of = root
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true
		scale_resize = false
		lock_bend = part.lock_bend
		value_type_show[POSITION] = false
		
		ds_list_add(other.part_list, id)
		
		tl_parent_set(other.id)
		tl_update_value_types()
		tl_update_type_name()
		tl_update_display_name()
		tl_update_depth()
		
		if (part.part_list != null && ds_list_size(part.part_list) > 0)
			new_tl_model_file_parts(root, part)
	}
}