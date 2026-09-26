/// temp_update_shape()

function temp_update_shape()
{
	if (shape_vbuffer)
		vbuffer_destroy(shape_vbuffer)
	
	var shapetype, rad, thflip, tvflip, tex1, tex2;
	shapetype = (id = app.bench_settings ? shape_type : type - e_temp_type.CUBE)
	rad = 8
	
	// Set texture
	thflip = negate(shape_tex_hmirror)
	tvflip = negate(shape_tex_vmirror)
	if (shape_invert)
		thflip *= -1
	
	tex1 = point2D(shape_tex_hoffset, shape_tex_voffset)
	tex2 = point2D(shape_tex_hoffset + shape_tex_hrepeat, shape_tex_voffset + shape_tex_vrepeat)
	
	if (thflip < 0)
	{
		tex1[X] = 1.0 - tex1[X]
		tex2[X] = 1.0 - tex2[X]
	}
	if (tvflip < 0)
	{
		tex1[Y] = 1.0 - tex1[Y]
		tex2[Y] = 1.0 - tex2[Y]
	}
	
	switch (shapetype)
	{
		case e_shape_type.SURFACE:
			shape_vbuffer = vbuffer_create_surface(rad, tex1, tex2, shape_invert)
			break
		
		case e_shape_type.CUBE:
			shape_vbuffer = vbuffer_create_cube(rad, tex1, tex2, thflip, tvflip, shape_invert, shape_tex_mapped)
			break
		
		case e_shape_type.CONE:
			shape_vbuffer = vbuffer_create_cone(rad, tex1, tex2, thflip, tvflip, shape_detail, shape_smooth, shape_closed, shape_invert, shape_tex_mapped)
			break
		
		case e_shape_type.CYLINDER:
			shape_vbuffer = vbuffer_create_cylinder(rad, tex1, tex2, thflip, tvflip, shape_detail, shape_smooth, shape_closed, shape_invert, shape_tex_mapped)
			break
		
		case e_shape_type.SPHERE:
			shape_vbuffer = vbuffer_create_sphere(rad, tex1, tex2, shape_detail, shape_smooth, shape_invert)
			break
	}
}
