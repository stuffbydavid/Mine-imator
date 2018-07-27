/// render_world_model_part(part, resource, texturenamemap, shapevbuffermap, colormap)
/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg shapevbuffermap
/// @arg colornamemap

var part, res, texnamemap, shapevbuffermap, colornamemap;
part = argument0
res = argument1
texnamemap = argument2
shapevbuffermap = argument3
colormap = argument4

if (part.shape_list = null)
	return 0
	
var parttexname, mat;
parttexname = model_part_get_texture_name(part, texnamemap)
mat = matrix_get(matrix_world)

for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	var shape, planevbuf;
	shape = part.shape_list[|s];
	
	// Check alpha if valid to render
	if (shape.color_alpha = 0)
		continue
	
	// Get texture (shape texture overrides part texture)
	var shapetexname = parttexname;
	if (shape.texture_name != "")
		shapetexname = shape.texture_name
			
	// Set shader
	with (res)
		render_set_texture(res_get_model_texture(shapetexname))
	
	// Set color
	var minecraft_color = c_white;
	if (colormap != null)
	{
		var color = colormap[? shape.description];
		if (!is_undefined(color))
			minecraft_color = color
	}
	
	if (minecraft_color = c_white)
		render_set_uniform_color("uBlendColor", color_multiply(shader_blend_color, shape.color_blend), shader_blend_alpha * shape.color_alpha)
	else
		render_set_uniform_color("uBlendColor", color_multiply(shader_blend_color, minecraft_color), shader_blend_alpha * shape.color_alpha)
	
	// Shape matrix
	var rendermatrix = matrix_multiply(shape.matrix, mat);
	
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
	
	// Main part mesh
	matrix_set(matrix_world, rendermatrix)
			
	// Pick vertex buffer from map if available
	if (shapevbuffermap != null && !is_undefined(shapevbuffermap[?shape]))
		vbuffer_render(shapevbuffermap[?shape])
}

matrix_set(matrix_world, mat)