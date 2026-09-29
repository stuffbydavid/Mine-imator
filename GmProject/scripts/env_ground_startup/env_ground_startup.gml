/// @desc Creates the vertex buffer for drawing the ground.

function env_ground_startup()
{
	var totalsize, size, rep;
	
	log("Ground vertexbuffer init")
	
	totalsize = (clip_far div 256) * 256
	size = totalsize / 16
	rep = size / 16
	
	env_ground_texture = null
	env_ground_texture_material = null
	env_ground_texture_normal = null
	env_ground_ani = false
	env_ground_material_ani = false
	env_ground_normal_ani = false
	env_ground_ani_texture[0] = null
	env_ground_ani_texture_material[0] = null
	env_ground_ani_tex_normal[0] = null
	
	env_ground_vbuffer = vbuffer_start()
	
	for (var xx = -totalsize; xx < totalsize; xx += size)
	{
		for (var yy = -totalsize; yy < totalsize; yy += size)
		{
			vertex_add_real(xx, yy, -0.01, 0, 0, 1, 0, 0)
			vertex_add_real(xx + size, yy, -0.01, 0, 0, 1, rep, 0)
			vertex_add_real(xx, yy + size, -0.01, 0, 0, 1, 0, rep)
			vertex_add_real(xx + size, yy, -0.01, 0, 0, 1, rep, 0)
			vertex_add_real(xx + size, yy + size, -0.01, 0, 0, 1, rep, rep)
			vertex_add_real(xx, yy + size, -0.01, 0, 0, 1, 0, rep)
		}
	}
	vbuffer_done()
}
