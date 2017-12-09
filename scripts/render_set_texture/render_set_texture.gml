/// render_set_texture(texture)
/// @arg texture
/// @desc Sets the texture of the currently selected shader.

var tex, sampler, scalex, scaley;
tex = argument0
sampler = render_shader_obj.sampler_map[?"uTexture"]
scalex = 1
scaley = 1

if (is_undefined(sampler) || sampler < 0)
	return 0

// Set filter
gpu_set_texfilter_ext(sampler, shader_texture_filter_linear)
gpu_set_tex_mip_enable(test(shader_texture_filter_mipmap, mip_on, mip_off))
gpu_set_tex_mip_filter_ext(sampler, tf_linear)

// Surface
if (shader_texture_surface)
{
	if (surface_exists(tex))
		texture_set_stage(sampler, surface_get_texture(tex))
	else
		texture_set_stage(sampler, 0)
}

// Sprite texture
else
{
	if (sprite_exists(tex))
	{
		texture_set_stage(sampler, sprite_get_texture(tex, 0))
		
		// GM sprite bug workaround
		// http://bugs.yoyogames.com/view.php?id=26268
		// When looking up added sprite textures using Texture2D in shaders,
		// their dimensions are limited to powers of 2, leading to graphical bugs.
		var wid, hei;
		wid = texture_width(tex)
		hei = texture_height(tex)
		scalex = wid / power(2, ceil(log2(wid))) 
		scaley = hei / power(2, ceil(log2(hei)))
	}
	else
		texture_set_stage(sampler, 0)
}

render_set_uniform_vec2("uTexScale", scalex, scaley)
gpu_set_texrepeat_ext(sampler, true)