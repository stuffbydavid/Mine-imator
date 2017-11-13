/// render_world_model_part(part, resource, texturenamemap, bendangle, bendvbufferlist, planevbuffermap)
/// @arg part
/// @arg resource
/// @arg texturenamemap
/// @arg bendangle
/// @arg bendvbufferlist
/// @arg planevbuffermap

var part, res, texnamemap, bendangle, bendvbufferlist, planevbuffermap, mat;
part = argument0
res = argument1
texnamemap = argument2
bendangle = argument3
bendvbufferlist = argument4
planevbuffermap = argument5
mat = matrix_get(matrix_world)

if (part.shape_list != null)
{
	var parttexname = model_part_get_texture_name(part, texnamemap);
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		var shape, planevbuf;
		shape = part.shape_list[|s];
		
		// Get texture (shape texture overrides part texture)
		var shapetexname = parttexname;
		if (shape.texture_name != "")
			shapetexname = shape.texture_name
			
		// Set shader
		with (res)
			render_set_texture(res_get_model_texture(shapetexname))
			
		// Main part mesh
		if (shape.bend_mode = e_shape_bend.LOCK_MOVING) // Lock to moving half
			matrix_set(matrix_world, matrix_multiply(matrix_multiply(shape.matrix, model_part_get_bend_matrix(part, bendangle, shape.position)), mat))
		else
			matrix_set(matrix_world, matrix_multiply(shape.matrix, mat))
		vbuffer_render(shape.vbuffer)
		
		if (shape.type = "plane" && shape.is3d)
		{
			planevbuf = planevbuffermap[?shape];
			vbuffer_render(planevbuf[0])
		}
		
		// Bended half
		if (part.bend_part != null && shape.bend_mode = e_shape_bend.BEND)
		{
			// Connect mesh
			if (bendangle != 0 && bendvbufferlist != null && bendvbufferlist[|s] != null)
			{
				matrix_set(matrix_world, matrix_multiply(matrix_multiply(model_part_get_bend_matrix(part, 0, shape.position), shape.matrix_bend_half), mat))
				vbuffer_render(bendvbufferlist[|s])
			}
			
			// Second half mesh
			matrix_set(matrix_world, matrix_multiply(matrix_multiply(model_part_get_bend_matrix(part, bendangle, shape.position), shape.matrix_bend_half), mat))
			vbuffer_render(shape.bend_vbuffer)
			
			if (shape.type = "plane" && shape.is3d)
				vbuffer_render(planevbuf[1])
		}
	}
}

matrix_set(matrix_world, mat)