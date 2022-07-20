/// vbuffer_generate_tangents(vbuffer)
/// @arg vbuffer
/// @desc Reads a vertex buffer and calculates tangents using UV and positions in triangles

function vbuffer_generate_tangents(vbuffer)
{
	var size, p, uv, t, seekpos, seekend;
	var edge1, edge2, deltaUV1, deltaUV2, f;
	size = vertex_get_number(vbuffer)
	
	// Empty
	if (size < 4)
		return vbuffer
	
	// Get buffer data
	var vertex_data = buffer_create_from_vertex_buffer(vbuffer, buffer_grow, 1);
	vbuffer_destroy(vbuffer)
	
	for (var i = 0; i < size; i += 3)
	{
		// Read 3 vertices
		for (var j = 0; j <= 2; j++)
		{
			// Position
			p[j][X] = buffer_read(vertex_data, buffer_f32)
			p[j][Y] = buffer_read(vertex_data, buffer_f32)
			p[j][Z] = buffer_read(vertex_data, buffer_f32)
			
			// Normal
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			
			// Color + Alpha
			buffer_read(vertex_data, buffer_u32)
			
			// UV
			uv[j][X] = buffer_read(vertex_data, buffer_f32)
			uv[j][Y] = buffer_read(vertex_data, buffer_f32)
			
			// Custom
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			
			// Tangent
			seekpos[j] = buffer_tell(vertex_data)
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
			buffer_read(vertex_data, buffer_f32)
		}
		seekend = buffer_tell(vertex_data)
		
		// First triangle is empty
		if (i = 0)
			continue
		
		// Calculate tangent
		edge1 = point3D_sub(p[1], p[0])
		edge2 = point3D_sub(p[2], p[0])
		deltaUV1 = point2D_sub(uv[1], uv[0])
		deltaUV2 = point2D_sub(uv[2], uv[0])
		f = 1 / (deltaUV1[X] * deltaUV2[Y] - deltaUV2[X] * deltaUV1[Y])
		
		t = vec3_normalize(vec3_mul(vec3_sub(vec3_mul(edge1, deltaUV2[Y]), vec3_mul(edge2, deltaUV1[Y])), f))
		
		// Write tangent for triangle
		for (var j = 0; j <= 2; j++)
		{
			buffer_seek(vertex_data, buffer_seek_start, seekpos[j])
			buffer_write(vertex_data, buffer_f32, t[X])
			buffer_write(vertex_data, buffer_f32, t[Y])
			buffer_write(vertex_data, buffer_f32, t[Z])
		}
		
		buffer_seek(vertex_data, buffer_seek_start, seekend)
	}
	
	vbuffer = vertex_create_buffer_from_buffer(vertex_data, vertex_format)
	buffer_delete(vertex_data)
	
	return vbuffer
}