/// render_world_model_part(part, resource, texturenamemap, shapevbuffermap, colormap, shapehidelist, shapetexnamemap, shapetexnamemap, tlobject)
/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg shapevbuffermap
/// @arg colornamemap
/// @arg shapehidelist
/// @arg shapetexnamemap
/// @arg tlobject

var part, res, texnamemap, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, tlobject;
part = argument0
res = argument1
texnamemap = argument2
shapevbuffermap = argument3
colornamemap = argument4
shapehidelist = argument5
shapetexnamemap = argument6
tlobject = argument7

if (part.shape_list = null)
	return 0
	
var parttexname, mat;
parttexname = model_part_get_texture_name(part, texnamemap)

if (!tlobject)
	mat = matrix_get(matrix_world)

for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	var shape;
	shape = part.shape_list[|s];
	
	// Hidden?
	if (shapehidelist != null && ds_list_find_index(shapehidelist, shape.description) > -1)
		continue
	
	// Check alpha if valid to render
	if (shape.color_alpha = 0)
		continue
	
	// Does the part need to move a certain amount for this shape to render?
	if (shape.move_required)
	{
		if (tlobject = null)
			continue
		
		if (!(abs(tlobject.value[e_value.POS_X]) > shape.move_required_array[X] &&
		abs(tlobject.value[e_value.POS_Y]) > shape.move_required_array[Y] &&
		abs(tlobject.value[e_value.POS_Z]) > shape.move_required_array[Z]))
			continue
	}
	
	// Get texture (shape texture overrides part texture)
	var shapetexname = parttexname;
	if (shape.texture_name != "")
		shapetexname = shape.texture_name
	
	// Change texture if name is in shape texture map
	if (shapetexnamemap != null)
	{
		var maptexname = shapetexnamemap[? shape.description];
		if (!is_undefined(maptexname))
			shapetexname = maptexname
	}
	
	// Set shader
	with (res)
		render_set_texture(res_get_model_texture(shapetexname))
	
	// Banner rendering
	if (part.is_banner)
	{
		// Preview/timeline
		if (object_index = obj_preview)
		{
			if (sprite_exists(select.banner_skin))
				render_set_texture(select.banner_skin)
		}
		else
		{
			// Only use banner skin if timeline is using its template's resource
			var tempres = null;
			
			with (tlobject.temp)
				tempres = temp_get_model_texobj(null)
			
			if (res = tempres)
				if (sprite_exists(tlobject.temp.banner_skin))
					render_set_texture(tlobject.temp.banner_skin)
		}
	}
	
	if (tlobject != null)
	{
		// Only use banner skin if timeline is using its template's resource
		var tempres = null;
		
		with (tlobject.temp)
			tempres = temp_get_model_texobj(null)
		
		if (res = tempres)
			if (sprite_exists(tlobject.banner_skin))
				render_set_texture(tlobject.banner_skin)
	}
	
	
	// Blend color
	var minecraft_color = c_white;
	if (colornamemap != null)
	{
		var color = colornamemap[? shape.description];
		if (!is_undefined(color))
			minecraft_color = color
	}
	
	// Minecraft color (Overrides shapes' blend color)
	if (minecraft_color = c_white)
		render_set_uniform_color("uBlendColor", color_multiply(shader_blend_color, shape.color_blend), shader_blend_alpha * shape.color_alpha)
	else
		render_set_uniform_color("uBlendColor", color_multiply(shader_blend_color, minecraft_color), shader_blend_alpha * shape.color_alpha)
	
	// Mix color
	if (shape.color_mix_percent > 0)
	{
		if (tlobject != null)
			render_set_uniform_color("uMixColor", merge_color(shape.color_mix, value_inherit[e_value.MIX_COLOR], value_inherit[e_value.MIX_PERCENT]), lerp(shape.color_mix_percent, value_inherit[e_value.MIX_PERCENT], value_inherit[e_value.MIX_PERCENT]))
		else
			render_set_uniform_color("uMixColor", shape.color_mix, shape.color_mix_percent)
	}
	
	// Shape matrix
	var rendermatrix;
	if (tlobject)
		rendermatrix  =matrix_multiply(shape.matrix, matrix)
	else
		rendermatrix = matrix_multiply(shape.matrix, mat)
	
	// Bounce
	if (shape.item_bounce)
	{
		var d, t, offz;
		d = 60 * 3
		t = current_step mod d * 2
		if (t < d)
			offz = ease("easeinoutquad", t / d) * 2 - 1
		else
			offz = 1 - ease("easeinoutquad", (t - d) / d) * 2
		rendermatrix = matrix_multiply(rendermatrix, matrix_build(0, 0, offz, 0, 0, 0, 1, 1, 1))
	}
	
	// Face camera
	if (shape.face_camera)
	{
		var rotx, rotz, rotmat;
		
		matrix_remove_rotation(rendermatrix)
		rotx = -point_zdirection(rendermatrix[MAT_X], rendermatrix[MAT_Y], rendermatrix[MAT_Z], proj_from[X], proj_from[Y], proj_from[Z])
		rotz = 90 + point_direction(rendermatrix[MAT_X], rendermatrix[MAT_Y], proj_from[X], proj_from[Y])
		rotmat = matrix_build(0, 0, 0, rotx, 0, rotz, 1, 1, 1)
		rendermatrix = matrix_multiply(rotmat, rendermatrix)
	}
	
	// Pick vertex buffer from map if available
	if (shapevbuffermap != null && !is_undefined(shapevbuffermap[?shape]))
		vbuffer_render_matrix(shapevbuffermap[?shape], rendermatrix)
}

if (!tlobject)
	matrix_set(matrix_world, mat)