/// lib_frustum()
/// @desc Functions library for making and editing view frustums

function frustum() constructor {
	
	active = true
	vbuffer = null
	corners = array_create(8, vec4(0))
	
	near = 0
	far = 0
	matView = null
	matProj = null
	matBias = null
	clipEndDepth = 0
	
	self.reset()
	
	static reset = function()
	{
		p[0] = [ 1,  0,  0, 1] // Left
		p[1] = [-1,  0,  0, 1] // Right
		p[2] = [ 0,  1,  0, 1] // Bottom
		p[3] = [ 0, -1,  0, 1] // Top
		p[4] = [ 0,  0,  1, 1] // Behind view
		p[5] = [ 0,  0, -1, 1] // Beyond view
	}
	
	static build = function(matVP, ortho = false)
	{
		var matVPt = matrix_transpose(matVP);
		var matVPi = matrix_inverse(matVP);
		self.reset()
		
		for (var i = 0; i < 6; i++)
		{
			var mul = vec4_mul_matrix(p[i], matVPt);
			p[i] = vec4_div(mul, vec3_length(vec3(mul[X], mul[Y], mul[Z])))
		}
		
		var corners_v4, near;
		near = (ortho ? -1 : 0)
		corners_v4 = [
			[-1,  1,    1, 1], // Far
			[ 1,  1,    1, 1],
			[ 1, -1,    1, 1],
			[-1, -1,    1, 1],
			[-1,  1, near, 1], // Near
			[ 1,  1, near, 1],
			[ 1, -1, near, 1],
			[-1, -1, near, 1]
		];
		
		for (var i = 0; i < 8; i++)
		{
			corners[i] = vec4_homogenize(vec4_mul_matrix(corners_v4[i], matVPi))
			corners[i][W] = 1
		}
	}
	
	static add_triangle = function(corner1, corner2, corner3) {
		vbuffer_add_triangle(corners[corner1], corners[corner2], corners[corner3], [0, 0], [0, 0], [0, 0])
	}
	
	static build_vbuffer = function(color = c_white)
	{
		if (vbuffer != null)
			vbuffer_destroy(vbuffer)
		
		// Generate mesh
		vertex_emissive = 1
		vertex_alpha = 0.5
		
		vbuffer_start()
		
		vertex_rgb = color_multiply(color, c_dkgrey)
		add_triangle(0, 4, 5); add_triangle(5, 1, 0); // X-
		
		vertex_rgb = color_multiply(color, c_ltgrey)
		add_triangle(7, 3, 2); add_triangle(2, 6, 7); // X+
		
		vertex_rgb = color_multiply(color, c_grey)
		add_triangle(2, 1, 5); add_triangle(5, 6, 2); // Y-
		add_triangle(7, 4, 0); add_triangle(0, 3, 7); // Y+
		
		vertex_rgb = color
		add_triangle(0, 1, 2); add_triangle(2, 3, 0); // Z-
		add_triangle(4, 7, 6); add_triangle(6, 5, 4); // Z+
		
		vbuffer = vbuffer_done()
		
		vertex_emissive = 0
		vertex_alpha = 1
		vertex_rgb = c_white
	}
}