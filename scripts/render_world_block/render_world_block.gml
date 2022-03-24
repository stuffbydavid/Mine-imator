/// render_world_block(vbuffer, resource, [rotate, size, [temp]])
/// @arg vbuffer
/// @arg resource
/// @arg [rotate
/// @arg size[
/// @arg temp]]

function render_world_block()
{
	var vbuffer, res, rotate, size, temp;
	vbuffer = argument[0]
	res = argument[1]
	
	if (argument_count > 2)
	{
		rotate = argument[2]
		size = argument[3]
	}
	else
		rotate = false
	
	if (argument_count > 4)
		temp = argument[4]
	else
		temp = null
	
	if (vbuffer = null)
		return 0
	
	if (!is_array(res))
		res = [res, mc_res, mc_res]
	
	if (!res_is_ready(res[0]))
		res[0] = mc_res
	
	if (!res_is_ready(res[1]))
		res[1] = mc_res
	
	if (!res_is_ready(res[2]))
		res[2] = mc_res
	
	var tex, texprev, texani;
	var texmat, texmatprev, texanimat;
	var texnormal, texnormalprev, texaninormal;
	
	render_set_uniform_int("uMaterialUseGlossiness", res[1].material_uses_glossiness)
	
	tex = res[0].block_sheet_texture
	texmat = res[1].block_sheet_texture_material
	texnormal = res[2].block_sheet_tex_normal
	
	texprev = tex
	texmatprev = texmat
	texnormalprev = texnormal
	
	if (res[0].block_sheet_ani_texture != null)
		texani = res[0].block_sheet_ani_texture[block_texture_get_frame()]
	else
		texani = mc_res[0].block_sheet_ani_texture[block_texture_get_frame()]
	
	if (res[1].block_sheet_ani_texture_material != null)
		texanimat = res[1].block_sheet_ani_texture_material[block_texture_get_frame()]
	else
		texanimat = mc_res[0].block_sheet_ani_texture_material[block_texture_get_frame()]
	
	// Set material values
	if (res[1] != mc_res)
	{
		if (shader_uniform_metallic != 1)
		{
			shader_uniform_metallic = 1
			render_set_uniform("uMetallic", shader_uniform_metallic)
		}
		
		if (shader_uniform_roughness != 0)
		{
			shader_uniform_roughness = 0
			render_set_uniform("uRoughness", shader_uniform_roughness)
		}
		
		if (shader_uniform_brightness != 1)
		{
			shader_uniform_brightness = 1
			render_set_uniform("uBrightness", shader_uniform_brightness)
		}
	}
	
	if (res[2].block_sheet_ani_tex_normal != null)
		texaninormal = res[2].block_sheet_ani_tex_normal[block_texture_get_frame()]
	else
		texaninormal = mc_res[0].block_sheet_ani_tex_normal[block_texture_get_frame()]
	
	var blend = shader_blend_color;
	render_set_texture(tex)
	render_set_texture(texmat, "Material")
	render_set_texture(texnormal, "Normal")
	
	// Rotate by 90 degrees for legacy support
	if (rotate && (!dev_mode || dev_mode_rotate_blocks))
		matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	
	#region Depth 0
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL])
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_grass), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS])
		render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	}
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		
		if (texanimat != texmatprev)
		{
			render_set_texture(texanimat, "Material")
			texmatprev = texanimat
		}
		
		if (texaninormal != texnormalprev)
		{
			render_set_texture(texaninormal, "Normal")
			texnormalprev = texaninormal
		}
		
		vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED])	
	}
	
	render_set_texture(tex)
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (texmat != texmatprev)
	{
		render_set_texture(texmat, "Material")
		texmatprev = texmat
	}
	
	if (texnormal != texnormalprev)
	{
		render_set_texture(texnormal, "Normal")
		texnormalprev = texnormal
	}
	
	#endregion
	
	#region Depth 1
	var filterprev;
	
	// Disable texture filtering on transparent blocks
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
	{
		filterprev = gpu_get_tex_mip_bias()
		gpu_set_tex_mip_bias(-16)
		
		render_set_texture(tex)
		texprev = tex
		
		render_set_texture(texmat, "Material")
		texmatprev = texmat
		
		render_set_texture(texnormal, "Normal")
		texnormalprev = texnormal
	}
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL])
	
	// Grass 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_grass), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS])
	}
	
	// Foliage 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.FOLIAGE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_foliage), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.FOLIAGE])
	}
	
	// Oak leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_oak), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_OAK])
	}
	
	// Spruce leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_SPRUCE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_spruce), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_SPRUCE])
	}
	
	// Birch leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_BIRCH]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_birch), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_BIRCH])
	}
	
	// Jungle leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_JUNGLE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_jungle), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_JUNGLE])
	}
	
	// Acacia leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_ACACIA]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_acacia), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_ACACIA])
	}
	
	// Dark oak leaves 
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_DARK_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_dark_oak), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_DARK_OAK])
	}
	
	render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(filterprev)
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		
		if (texanimat != texmatprev)
		{
			render_set_texture(texanimat, "Material")
			texmatprev = texanimat
		}
		
		if (texaninormal != texnormalprev)
		{
			render_set_texture(texaninormal, "Normal")
			texnormalprev = texaninormal
		}
		
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED])	
	}
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (texmat != texmatprev)
	{
		render_set_texture(texmat, "Material")
		texmatprev = texmat
	}
	
	if (texnormal != texnormalprev)
	{
		render_set_texture(texnormal, "Normal")
		texnormalprev = texnormal
	}
	
	render_set_texture(tex)
	
	#endregion
	
	#region Depth 2
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL])
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_set_texture(texanimat, "Material")
		render_set_texture(texaninormal, "Normal")
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED])
	}
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER]))
	{
		if (render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
		{
			render_set_texture(texani)
			
			/*
			render_set_texture(texanimat, "Material")
			render_set_texture(texaninormal, "Normal")
			*/
			
			render_set_texture(spr_default_material, "Material")
			render_set_texture(spr_default_normal, "Normal")
			
			render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_water), shader_blend_alpha)
			render_set_uniform_int("uIsWater", 1)
			
			if (shader_uniform_roughness != 0.2)
			{
				shader_uniform_roughness = 0.2
				render_set_uniform("uRoughness", shader_uniform_roughness)
			}
			
			if (shader_uniform_metallic != 0.0)
			{
				shader_uniform_metallic = 0.0
				render_set_uniform("uMetallic", shader_uniform_metallic)
			}
			
			if (shader_uniform_brightness != 0.0)
			{
				shader_uniform_brightness = 0.0
				render_set_uniform("uBrightness", shader_uniform_brightness)
			}
			
			vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER])
		}
	}
	
	#endregion
}
