/// CppSeparate void block_render_model_generate(Scope<obj_builder_thread>, IntType)
/// @desc Generate triangles from the render model.

function block_render_model_generate(model)
{
	instance_activate_object(model)
	
	var offx, offy, offz;
	offx = block_pos[X] + model.offset[X]
	offy = block_pos[Y] + model.offset[Y]
	offz = block_pos[Z] + model.offset[Z]

	// Set emissive
	if (block_vertex_emissive = null)
		block_vertex_emissive = model.emissive
	
	var minemissive = block_vertex_emissive;

	// Generate elements
	for (var e = 0; e < model.element_amount; e++)
	{
		var el, mat, fromx, fromy, fromz, tox, toy, toz;
		el = model.element[e]
		instance_activate_object(el)
		
		fromx = el.from[X]
		fromy = el.from[Y]
		fromz = el.from[Z]
		tox = el.to[X]
		toy = el.to[Y]
		toz = el.to[Z]

		// Apply offset to transformation matrix if rotated
		if (el.rotated)
			mat = matrix_multiply(el.matrix, matrix_build(offx, offy, offz, 0, 0, 0, 1, 1, 1))
		else
		{
			mat = null
			
			fromx += offx
			fromy += offy
			fromz += offz
			tox += offx
			toy += offy
			toz += offz
		}

		// Light emission for individual elements
		block_vertex_emissive = max(minemissive, el.light_emission / 15)
		for (var f = 0; f < block_faces; f++)
		{
			if (!el.face_render[f] || block_render_model_generate_face_cull(model, el, f))
				continue

			if (block_color = null)
				block_vertex_rgb = el.face_texture_color[f]
			else
				block_vertex_rgb = block_color

			block_vbuffer_current = el.face_vbuffer[f]
			if (block_vbuffer_current = null)
			{
				var index = el.face_depth[f] * e_block_vbuffer.amount + el.face_block_vbuffer[f];
				block_vbuffer_current = block_mesh.block_vbuffer[@index]
			}

			// Read the four UV coordinates once per face
			var uv0, uv1, uv2, uv3;
			uv0 = el.face_uv[f, 0]
			uv1 = el.face_uv[f, 1]
			uv2 = el.face_uv[f, 2]
			uv3 = el.face_uv[f, 3]

			switch (f)
			{
				case XP:
				{
					builder_add_face_real(
						tox, toy, toz, tox, fromy, toz, tox, fromy, fromz, tox, toy, fromz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
				
				case XN:
				{
					builder_add_face_real(
						fromx, fromy, toz, fromx, toy, toz, fromx, toy, fromz, fromx, fromy, fromz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
				
				case YP:
				{
					builder_add_face_real(
						fromx, toy, toz, tox, toy, toz, tox, toy, fromz, fromx, toy, fromz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
				
				case YN:
				{
					builder_add_face_real(
						tox, fromy, toz, fromx, fromy, toz, fromx, fromy, fromz, tox, fromy, fromz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
				
				case ZP:
				{
					builder_add_face_real(
						fromx, fromy, toz, tox, fromy, toz, tox, toy, toz, fromx, toy, toz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
				
				case ZN:
				{
					builder_add_face_real(
						fromx, toy, fromz, tox, toy, fromz, tox, fromy, fromz, fromx, fromy, fromz,
						uv0[X], uv0[Y], uv1[X], uv1[Y], uv2[X], uv2[Y], uv3[X], uv3[Y],
						mat
					)
					break
				}
			}
		}

		block_vertex_rgb = c_white
		block_vertex_emissive = minemissive
		
		instance_deactivate_object(el)
	}

	instance_deactivate_object(model)
}
