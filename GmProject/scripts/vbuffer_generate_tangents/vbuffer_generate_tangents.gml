/// @desc Reads a vertex buffer and calculates tangents using UV and positions in triangles.
/// @arg vertexbuffer

function vbuffer_generate_tangents(vbuffer)
{
	if (is_cpp() || debug_skip_tangents)
		return vbuffer
	
	var size, p, uv, t, seekpos, seekend;
	var edge1, edge2, deltauv1, deltauv2, f;
	size = vertex_get_number(vbuffer)
	
	// Empty
	if (size < 4)
		return vbuffer
	
	// Get buffer data
	var vertexdata = buffer_create_from_vertex_buffer(vbuffer, buffer_grow, 1);
	vbuffer_destroy(vbuffer)
	
	for (var i = 0; i < size; i += 3)
	{
		// Read 3 vertices
		for (var j = 0; j <= 2; j++)
		{
			// Position
			p[j][X] = buffer_read(vertexdata, buffer_f32)
			p[j][Y] = buffer_read(vertexdata, buffer_f32)
			p[j][Z] = buffer_read(vertexdata, buffer_f32)
			
			// Normal
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			
			// Color + Alpha
			buffer_read(vertexdata, buffer_u32)
			
			// UV
			uv[j][X] = buffer_read(vertexdata, buffer_f32)
			uv[j][Y] = buffer_read(vertexdata, buffer_f32)
			
			// Custom
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			
			// Tangent
			seekpos[j] = buffer_tell(vertexdata)
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
			buffer_read(vertexdata, buffer_f32)
		}
		seekend = buffer_tell(vertexdata)
		
		// First triangle is empty
		if (i = 0)
			continue
		
		// Calculate tangent
		edge1 = point3D_sub(p[1], p[0])
		edge2 = point3D_sub(p[2], p[0])
		deltauv1 = point2D_sub(uv[1], uv[0])
		deltauv2 = point2D_sub(uv[2], uv[0])
		f = 1 / (deltauv1[X] * deltauv2[Y] - deltauv1[Y] * deltauv2[X])
		
		t = vec3_normalize(vec3_mul(vec3_sub(vec3_mul(edge1, deltauv2[Y]), vec3_mul(edge2, deltauv1[Y])), f))
		
		// Write tangent for triangle
		for (var j = 0; j <= 2; j++)
		{
			buffer_seek(vertexdata, buffer_seek_start, seekpos[j])
			buffer_write(vertexdata, buffer_f32, t[X])
			buffer_write(vertexdata, buffer_f32, t[Y])
			buffer_write(vertexdata, buffer_f32, t[Z])
		}
		
		buffer_seek(vertexdata, buffer_seek_start, seekend)
	}
	
	vbuffer = vertex_create_buffer_from_buffer(vertexdata, vertex_format)
	buffer_delete(vertexdata)
	
	return vbuffer
}
