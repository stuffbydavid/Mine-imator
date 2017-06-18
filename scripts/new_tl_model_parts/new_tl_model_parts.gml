/// new_tl_model_parts(root, model)
/// @arg root
/// @arg model

var root, model;
root = argument0
model = argument1

for (var p = 0; p < model.part_amount; p++)
{
	var part = model.part[p];
	with (new(obj_timeline))
	{
		type = "bodypart"
		temp = other.temp
		bodypart = part
		part_of = root
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true
		scale_resize = false
		lock_bend = part.lock_bend
		value_type_show[POSITION] = false
		
		other.part[other.part_amount] = id
		other.part_amount++
		
		tl_parent_set(other.id)
		tl_update_value_types()
		tl_update_type_name()
		tl_update_display_name()
		tl_update_depth()
		
		new_tl_model_parts(root, part)
	}
}