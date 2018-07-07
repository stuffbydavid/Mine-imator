/// render_world_model_part(part, resource, texturenamemap, shapevbuffermap)
/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg shapevbuffermap

var part, res, texnamemap, shapevbuffermap;
part = argument0
res = argument1
texnamemap = argument2
shapevbuffermap = argument3

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
	render_set_uniform_color("uBlendColor", color_multiply(shader_blend_color, test(shape.minecraft_color = c_white, shape.color_blend, shape.minecraft_color)), shader_blend_alpha * shape.color_alpha)

	// Main part mesh
	matrix_set(matrix_world, matrix_multiply(shape.matrix, mat))
			
	// Pick vertex buffer from map if available
	if (shapevbuffermap != null && !is_undefined(shapevbuffermap[?shape]))
		vbuffer_render(shapevbuffermap[?shape])
}

matrix_set(matrix_world, mat)