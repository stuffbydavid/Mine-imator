/// render_generate_text_buffer(is3d, surf, xx, zz, wid, hei)

function render_generate_text_buffer(is3d, surf, xx, zz, wid, hei)
{
	vbuffer_start()
	
	// 3D pixels
	if (is3d)
		vbuffer_add_pixels(surface_get_alpha_array(surf), point3D(xx, 0, zz))
	
	var ysize, p1, p2, p3, p4, tsize, t1, t2, t3, t4;
	t1 = vec2(0, 0)
	t2 = vec2(wid, 0)
	t3 = vec2(wid, hei)
	t4 = vec2(0, hei)
	
	// Convert coordinates to 0-1
	ysize = (is3d ? 1 : 0)
	tsize = vec2(wid, hei)
	t1 = vec2_div(t1, tsize)
	t2 = vec2_div(t2, tsize)
	t3 = vec2_div(t3, tsize)
	t4 = vec2_div(t4, tsize)
	
	// Front
	p1 = point3D(xx, ysize, zz + hei)
	p2 = point3D(xx + wid, ysize, zz + hei)
	p3 = point3D(xx + wid, ysize, zz)
	p4 = point3D(xx, ysize, zz)
	vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
	vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
	
	// Back
	p1 = point3D(xx, 0, zz + hei)
	p2 = point3D(xx + wid, 0, zz + hei)
	p3 = point3D(xx + wid, 0, zz)
	p4 = point3D(xx, 0, zz)
	vbuffer_add_triangle(p2, p1, p3, t2, t1, t3)
	vbuffer_add_triangle(p4, p3, p1, t4, t3, t1)
	
	return vbuffer_done()
}
