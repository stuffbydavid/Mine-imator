/// render_world_model_part(part, texturenamemap, resource, bendangle, bendvbufferlist)
/// @arg part
/// @arg texturenamemap
/// @arg resource
/// @arg bendangle
/// @arg bendvbufferlist

var part, texnamemap, res, bendangle, bendvbufferlist;
part = argument0
texnamemap = argument1
res = argument2
bendangle = argument3
bendvbufferlist = argument4

if (part.shape_list != null)
{
	var texname = model_get_texture_name(texnamemap, part.name);
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		if (s>0) break
		var shape = part.shape_list[|s];
		
		// Get texture (shape texture overrides part texture)
		if (shape.texture_name != part.texture_name)
			texname = shape.texture_name
			
		// Set shader
		with (res)
			shader_texture = res_get_model_texture(texname)
		shader_use()
		
		// Main part mesh
		vbuffer_render(shape.vbuffer)
		
		// Bended half
		if (part.bend_part != null)
		{
			// Connect mesh
			if (bendangle != 0 && bendvbufferlist != null && bendvbufferlist[|s] != null)
				vbuffer_render(bendvbufferlist[|s])
		
			// Second half mesh
			var mat = matrix_get(matrix_world);
			matrix_set(matrix_world, matrix_multiply(model_part_bend_matrix(part, bendangle), mat))
			vbuffer_render(shape.bend_vbuffer)
			matrix_set(matrix_world, mat)
		}
	}
}