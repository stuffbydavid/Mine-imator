/// render_world_model_part(part, texturename, resource, bending)
/// @arg part
/// @arg texturename
/// @arg resource
/// @arg bending

var part, texname, res, bend;
part = argument0
texname = argument1
res = argument2
bend = argument3

if (part.shape_vbuffer != null)
{
	// Get texture
	with (res)
		shader_texture = res_get_model_texture(texname)
	shader_use()
		
	// Main part
	vbuffer_render(part.shape_vbuffer)
		
	// Bended half
	if (part.bend_part != null)
	{
		var mat = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_multiply(model_bend_matrix(part, bend), mat))
		vbuffer_render(part.shape_bend_vbuffer)
		matrix_set(matrix_world, mat)
	}
}