/// render_world_model_file_parts(modelfile, texturename, resource)
/// @arg modelfile
/// @arg texturename
/// @arg resource
/// @desc Renders a modelfile in its default position.

var modelfile, texname, res, mat;
modelfile = argument0
texname = argument1
res = argument2

mat = matrix_get(matrix_world)

for (var p = 0; p < modelfile.part_amount; p++) 
{
	var part = modelfile.part[p];
	if (part.shape_vbuffer != null)
	{
		// Get texture
		with (res)
			shader_texture = res_get_model_texture(texname)
		
		shader_use()
		
		// Main part
		matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
		vbuffer_render(part.shape_vbuffer)
		
		// Bended half
		if (part.bend_part != null)
		{
			matrix_set(matrix_world, matrix_multiply(matrix_multiply(model_bend_matrix(part, 0), part.default_matrix), mat))
			vbuffer_render(part.shape_bend_vbuffer)
		}
		
		// Reset world
		matrix_set(matrix_world, mat)
	}
	render_world_model_file_parts(part, texname, res)
}