/// render_world_model_parts(model, resource)
/// @arg model
/// @arg resource
/// @desc Renders a model in its default position.

var model, res, mat;
model = argument0
res = argument1

mat = matrix_get(matrix_world)

for (var p = 0; p < model.part_amount; p++) 
{
	var part = model.part[p];
	if (part.shape_vbuffer != null)
	{
		// Get texture
		with (res)
			shader_texture = res_model_texture(model)
		
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
	render_world_model_parts(part, res)
}