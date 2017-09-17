/// render_world_block(vbuffer, size, resource)
/// @arg vbuffer
/// @arg size
/// @arg resource

var vbuffer, size, res, img, blend, mipmap, tex, texani;
vbuffer = argument0
size = argument1
res = argument2

if (!res.ready)
	res = res_def

tex = res.block_sheet_texture
if (is_array(res.block_sheet_ani_texture))
	texani = res.block_sheet_ani_texture[block_texture_get_frame()]
else
	texani = res_def.block_sheet_ani_texture[block_texture_get_frame()]

blend = shader_blend_color
shader_texture = tex

// Rotate by 90 degrees for legacy support
matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))

// DEPTH 0

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL]))
{
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL])
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED]))
{
	shader_texture = texani
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED])
	shader_texture = tex
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS]))
{
	shader_blend_color = color_multiply(blend, res.color_grass)
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS])
	shader_blend_color = blend
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.LEAVES]))
{
	shader_blend_color = color_multiply(blend, res.color_foliage)
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.LEAVES])
	shader_blend_color = blend
}

// DEPTH 1

// Transparent stuff, no mipmapping
mipmap = shader_texture_filter_mipmap
shader_texture_filter_mipmap = app.setting_transparent_texture_filtering

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL]))
{
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL])
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED]))
{
	shader_texture = texani
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED])
	shader_texture = tex
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS]))
{
	shader_blend_color = color_multiply(blend, res.color_grass)
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS])
	shader_blend_color = blend
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES]))
{
	shader_blend_color = color_multiply(blend, res.color_foliage)
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES])
	shader_blend_color = blend
}

// Depth 2

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL]))
{
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL])
}

if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED]))
{
	shader_texture = texani
	shader_use()
	vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED])
	shader_texture = tex
}

shader_texture_filter_mipmap = mipmap
