/// draw_world_block(vbuffer, resource)
/// @arg vbuffer
/// @arg resource

var vbuffer, res, img, blend, mipmap, tex, texani;
vbuffer = argument0
res = argument1

if (!res.ready)
    res = res_def

tex = res.block_sheet_texture
texani = null
if (is_array(res.block_sheet_ani_texture))
	texani = res.block_sheet_ani_texture[block_texture_get_frame()]

blend = shader_blend_color
shader_texture = tex

matrix_add_offset()

// DEPTH 0

shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL])

shader_texture = texani
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED])
shader_texture = tex

shader_blend_color = color_multiply(blend, res.color_grass)
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS])
shader_blend_color = blend

shader_blend_color = color_multiply(blend, res.color_foliage)
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.LEAVES])
shader_blend_color = blend

// DEPTH 1

// Transparent stuff, no mipmapping
mipmap = shader_texture_filter_mipmap
shader_texture_filter_mipmap = app.setting_transparent_texture_filtering

shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL])

shader_texture = texani
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED])
shader_texture = tex

shader_blend_color = color_multiply(blend, res.color_grass)
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS])
shader_blend_color = blend

shader_blend_color = color_multiply(blend, res.color_foliage)
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES])
shader_blend_color = blend

// Depth 2

shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL])

shader_texture = texani
shader_use()
vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED])
shader_texture = tex

shader_texture_filter_mipmap = mipmap
