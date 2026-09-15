/// vbuffer_create_cube(radius, tex1, tex2, texhorflip, texverflip, invert, mapped)
/// @arg radius
/// @arg tex1
/// @arg tex2
/// @arg texhorflip
/// @arg texverflip
/// @arg invert
/// @arg mapped

function vbuffer_create_cube(rad, tex1, tex2, thflip, tvflip, invert, mapped)
{
	vbuffer_start()
	
	var texsize = point2D(1 / 3, 0.5);
	
	// X+
	if (mapped)
	{
		if (invert)
			tex1[X] = texsize[X]
		else
			tex1[X] = texsize[X] * 2
		
		tex1[Y] = 0
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(rad, rad, -rad, rad, rad, rad, rad, -rad, rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex1[Y], invert)
	vbuffer_add_triangle(rad, rad, -rad, rad, -rad, rad, rad, -rad, -rad, tex1[X], tex2[Y], tex2[X], tex1[Y], tex2[X], tex2[Y], invert)
	
	// X-
	if (mapped)
	{
		if (invert)
			tex1[X] = texsize[X] * 2
		else
			tex1[X] = texsize[X]
		
		tex1[Y] = 0
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(-rad, rad, rad, -rad, rad, -rad, -rad, -rad, rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex1[Y], invert)
	vbuffer_add_triangle(-rad, -rad, rad, -rad, rad, -rad, -rad, -rad, -rad, tex1[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y], invert)
	
	// Y+
	if (mapped)
	{
		tex1 = point2D(0, 0)
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(-rad, rad, rad, rad, rad, rad, rad, rad, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex2[X], tex2[Y], invert)
	vbuffer_add_triangle(-rad, rad, -rad, -rad, rad, rad, rad, rad, -rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex2[Y], invert)
	
	// Y-
	if (mapped)
	{
		tex1 = point2D(0, texsize[Y])
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(rad, -rad, rad, -rad, -rad, rad, rad, -rad, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex1[X], tex2[Y], invert)
	vbuffer_add_triangle(-rad, -rad, rad, -rad, -rad, -rad, rad, -rad, -rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y], invert)
	
	// Z+
	if (mapped)
	{
		tex1 = texsize
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(-rad, -rad, rad, rad, -rad, rad, -rad, rad, rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex1[X], tex2[Y], invert)
	vbuffer_add_triangle(rad, -rad, rad, rad, rad, rad, -rad, rad, rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y], invert)
	
	// Z-
	if (mapped)
	{
		tex1 = point2D(texsize[X] * 2, texsize[Y])
		tex2 = point2D_add(tex1, texsize)
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	vbuffer_add_triangle(rad, -rad, -rad, -rad, -rad, -rad, -rad, rad, -rad, tex2[X], tex2[Y], tex1[X], tex2[Y], tex1[X], tex1[Y], invert)
	vbuffer_add_triangle(rad, rad, -rad, rad, -rad, -rad, -rad, rad, -rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex1[Y], invert)
	
	return vbuffer_done()
}
