/// tl_copy(to)
/// @arg to
/// @desc Copies all the variables into the given object.

function tl_copy(to)
{
	to.type = type
	to.name = name
	to.temp = temp
	to.has_temp = has_temp
	to.text = text
	to.color_tag = color_tag
	to.lock = lock
	to.hide = hide
	to.ghost = ghost
	to.depth = depth
	
	to.lock_bend = lock_bend
	to.part_mixing_shapes = part_mixing_shapes
	to.parent = parent
	if (object_index = obj_timeline)
		to.parent_tree_index = ds_list_find_index(parent.tree_list, id)
	else // History object (copy)
		to.parent_tree_index = parent_tree_index
	to.tree_extend = tree_extend
	
	to.model_part = model_part
	to.model_part_name = model_part_name
	to.part_of = part_of
	
	to.inherit_position = inherit_position
	to.inherit_rotation = inherit_rotation
	to.inherit_rot_point = inherit_rot_point
	to.inherit_scale = inherit_scale
	to.inherit_alpha = inherit_alpha
	to.inherit_color = inherit_color
	to.inherit_visibility = inherit_visibility
	to.inherit_bend = inherit_bend
	to.inherit_texture = inherit_texture
	to.inherit_surface = inherit_surface
	to.inherit_subsurface = inherit_subsurface
	to.inherit_glow_color = inherit_glow_color
	to.inherit_select = inherit_select
	to.inherit_pose = inherit_pose
	to.scale_resize = scale_resize
	to.rot_point_custom = rot_point_custom
	to.rot_point = point3D_copy(rot_point)
	to.rot_point_render = point3D_copy(rot_point_render)
	to.backfaces = backfaces
	to.texture_blur = texture_blur
	to.texture_filtering = texture_filtering
	to.shadows = shadows
	to.ssao = ssao
	to.glow = glow
	to.glow_texture = glow_texture
	to.only_render_glow = only_render_glow
	to.glint_mode = glint_mode
	to.glint_scale = glint_scale
	to.glint_speed = glint_speed
	to.glint_strength = glint_strength
	to.glint_tex = glint_tex
	to.fog = fog
	to.wind = wind
	to.wind_terrain = wind_terrain
	to.hq_hiding = hq_hiding
	to.lq_hiding = lq_hiding
	to.blend_mode = blend_mode
	to.alpha_mode = alpha_mode
	
	to.path_update = true
	to.path_closed = path_closed
	to.path_smooth = path_smooth
	to.path_detail = path_detail
	to.path_shape = path_shape
	to.path_shape_radius = path_shape_radius
	to.path_shape_invert = path_shape_invert
	to.path_shape_smooth_segments = path_shape_smooth_segments
	to.path_shape_smooth_ring = path_shape_smooth_ring
	to.path_shape_detail = path_shape_detail
	to.path_shape_tex_mapped = path_shape_tex_mapped
	to.path_shape_tex_length = path_shape_tex_length
	
	if (type = e_tl_type.BLOCK && (part_of != null || !has_temp))
	{
		to.block_name = block_name
		to.block_state = array_copy_1d(block_state)
		if (part_of = null && !has_temp)
		{
			to.block_tex = block_tex
			to.block_tex_material = block_tex_material
			to.block_tex_normal = block_tex_normal
			to.block_repeat_enable = block_repeat_enable
			to.block_repeat = array_copy_1d(block_repeat)
			to.block_center_legacy = block_center_legacy
			to.block_center = block_center
			to.block_randomize = block_randomize
		}
	}
	else if (((type = e_tl_type.EQUIPMENT || type = e_tl_type.SPECIAL_BLOCK) && part_of != null && part_of != "") ||
		(type = e_tl_type.SPECIAL_BLOCK && !has_temp))
	{
		to.model_name = model_name
		to.model_state = array_copy_1d(model_state)
		if (part_of = null && !has_temp)
		{
			to.model_tex = model_tex
			to.model_tex_material = model_tex_material
			to.model_tex_normal = model_tex_normal
			to.model_use_blend_color = model_use_blend_color
			to.model_blend_color = model_blend_color
			to.model_blend_color_default = model_blend_color_default
		}
	}
}
