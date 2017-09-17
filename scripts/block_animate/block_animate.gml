/// block_animate(creator, size)
/// @arg creator
/// @arg size

var creator, size, temp, type;
creator = argument0
size = argument1
temp = null
	
// Type to create
if (model_name != "")
	type = "spblock"
else
	type = "block"

// Find existing template to re-use
with (obj_template)
{
	if (id.creator != creator || id.type != type)
		continue
		
	if ((model_name = other.model_name && model_state = other.model_state) ||
	    (block_name = other.block.name && block_state = other.block.default_state))
	{
		temp = id
		break
	}
}
	
// Create new
if (temp = null)
{
	with (new(obj_template))
	{
		id.type = type
		id.creator = creator
		
		model_name = other.model_name
		model_state = other.model_state
		block_name = other.block.name
		block_state = other.block.default_state
		
		if (type = "spblock")
		{
			skin = res_def // TODO same as template?
			skin.count++
		}
		else
		{
			block_tex = res_def
			block_tex.count++
		}
		
		temp_update()
		sortlist_add(app.lib_list, id)
		temp = id
	}
}
	
var tl;
with (temp)
	tl = temp_animate()
		
with (tl)
{
	rot_point_custom = true
	rot_point = array_copy_1d(other.rot_point)
		
	// Rotate by 90 degrees for legacy support
	var pos = point3D_mul_matrix(other.position, matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	value_default[e_value.POS_X] = snap(pos[X], 0.5)
	value_default[e_value.POS_Y] = snap(pos[Y], 0.5)
	value_default[e_value.POS_Z] = snap(pos[Z], 0.5)
	value_default[e_value.ROT_X] = other.rotation[X]
	value_default[e_value.ROT_Y] = other.rotation[Y]
	value_default[e_value.ROT_Z] = other.rotation[Z] + 90
		
	tl_update_values()
	return id
}