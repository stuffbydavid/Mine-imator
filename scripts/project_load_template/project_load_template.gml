/// project_load_template(map)
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0

with (new(obj_template))
{
	loaded = true
	
	load_id = value_get_string(map[?"id"], save_id)
	save_id_map[?load_id] = load_id
	
	type = value_get_string(map[?"type"], type)
	name = value_get_string(map[?"name"], name)

	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		skin = value_get_save_id(map[?"skin"], skin)
		var modelmap = map[?"model"];
		if (ds_map_valid(modelmap))
		{
			model_name = value_get_string(modelmap[?"name"], model_name)
			model_state = value_get_state_vars(modelmap[?"state"])
			if (type = "bodypart")
				model_part_name = value_get_string(modelmap[?"part_name"], model_part_name)
		}
	}
	else if (type = "item")
	{
		var itemmap = map[?"item"];
		if (ds_map_valid(itemmap))
		{
			item_tex = value_get_save_id(itemmap[?"tex"], item_tex)
			if (!is_undefined(itemmap[?"name"]))
				item_slot = ds_list_find_index(mc_assets.item_texture_list, value_get_string(itemmap[?"name"]))
			else
				item_slot = value_get_real(itemmap[?"slot"], item_slot)
			item_3d = value_get_real(itemmap[?"3d"], item_3d)
			item_face_camera = value_get_real(itemmap[?"face_camera"], item_face_camera)
			item_bounce = value_get_real(itemmap[?"bounce"], item_bounce)
		}
	}
	else if (type = "block")
	{
		var blockmap = map[?"block"];
		if (ds_map_valid(blockmap))
		{
			block_name = value_get_string(blockmap[?"name"], block_name)
			block_state = value_get_state_vars(blockmap[?"state"])
			
			/*block_legacy_id = value_get_real(blockmap[?"legacy_id"], 2)
			block_legacy_data = value_get_real(blockmap[?"legacy_data"], 0)
			var block = mc_assets.block_legacy_id_map[?block_legacy_id];
			if (!is_undefined(block))
			{
				block_name = block.name
				block_state = array_copy_1d(block.legacy_data_state[block_legacy_data])
			}*/
			
			block_tex = value_get_save_id(blockmap[?"tex"], block_tex)
			block_repeat_enable = value_get_real(blockmap[?"repeat_enable"], block_repeat_enable)
			block_repeat = value_get_point3D(blockmap[?"repeat"], block_repeat)
		}
	}
	if (type = "scenery")
	{
		scenery = value_get_save_id(map[?"scenery"], scenery)
		var blockmap = map[?"block"];
		if (ds_map_valid(blockmap))
		{
			block_tex = value_get_save_id(blockmap[?"tex"], block_tex)
			block_repeat_enable = value_get_real(blockmap[?"repeat_enable"], block_repeat_enable)
			block_repeat = value_get_point3D(blockmap[?"repeat"], block_repeat)
		}
	}
	
	if (type_is_shape(type))
	{
		var shapemap = map[?"shape"];
		if (ds_map_valid(shapemap))
		{
			shape_tex = value_get_save_id(shapemap[?"tex"], shape_tex)
			shape_tex_mapped = value_get_real(shapemap[?"tex_mapped"], shape_tex_mapped)
			shape_tex_hoffset = value_get_real(shapemap[?"tex_hoffset"], shape_tex_hoffset)
			shape_tex_voffset = value_get_real(shapemap[?"tex_voffset"], shape_tex_voffset)
			shape_tex_hrepeat = value_get_real(shapemap[?"tex_hrepeat"], shape_tex_hrepeat)
			shape_tex_vrepeat = value_get_real(shapemap[?"tex_vrepeat"], shape_tex_vrepeat)
			shape_tex_hmirror = value_get_real(shapemap[?"tex_hmirror"], shape_tex_hmirror)
			shape_tex_vmirror = value_get_real(shapemap[?"tex_vmirror"], shape_tex_vmirror)
			shape_closed = value_get_real(shapemap[?"closed"], shape_closed)
			shape_invert = value_get_real(shapemap[?"invert"], shape_invert)
			shape_detail = value_get_real(shapemap[?"detail"], shape_detail)
			shape_face_camera = value_get_real(shapemap[?"face_camera"], shape_face_camera)
		}
	}
	else if (type = "text")
	{
		var textmap = map[?"text"];
		if (ds_map_valid(textmap))
		{
			text_font = value_get_save_id(textmap[?"font"], text_font)
			text_3d = value_get_real(textmap[?"3d"], text_3d)
			text_face_camera = value_get_real(textmap[?"face_camera"], text_face_camera)
		}
	}
	else if (type = "particles")
		project_load_particles(map[?"particles"])
	
	if (temp_creator = app)
		sortlist_add(app.lib_list, id)
}