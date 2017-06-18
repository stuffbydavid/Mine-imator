/// render_world_model_parts(model, resource)
/// @arg model
/// @arg resource
/// @desc Renders a model in its default position

var model, res;
model = argument0
res = argument1

for (var p = 0; p < model.part_amount; p++) 
{
	var part = model.part[p];
	if (part.shape_vbuffer != null)
	{
		with (res)
			shader_texture = res_model_texture(model)
		shader_use()
		matrix_set(matrix_world, part.default_matrix)
		vbuffer_render(part.shape_vbuffer)
		
		if (part.bend_part != null)
		{
			matrix_set(matrix_world, matrix_multiply(model_bend_matrix(part, 0), part.default_matrix))
			vbuffer_render(part.shape_bend_vbuffer)
		}
		matrix_world_reset()
	}
	render_world_model_parts(part, res)
}