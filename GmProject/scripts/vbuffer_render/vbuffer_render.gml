/// @arg vertexbuffer
/// @arg [position]
/// @arg [rotation]
/// @arg [scale]

function vbuffer_render(vbuf, pos = null, rot = null, sca = null)
{
	if (vbuf = null)
		return false
		
	if (is_array(pos))
	{
		if (!is_array(rot))
			rot = vec3(0)
		
		if (!is_array(sca))
			sca = vec3(1)
			
		var mat = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_create(pos, rot, sca))
		vertex_submit(vbuf, pr_trianglelist, -1)
		matrix_set(matrix_world, mat)
	}
	else
		vertex_submit(vbuf, pr_trianglelist, -1)
}
