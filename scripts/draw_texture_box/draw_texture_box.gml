/// draw_texture_box(texture, x, y, width, height)
/// @arg texture
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var tex, xx, yy, w, h;
tex = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4

shader_texture = tex
shader_draw_texture_set()

draw_primitive_begin(pr_trianglestrip)

draw_vertex_texture(xx, yy, 0, 0)
draw_vertex_texture(xx + w, yy, 1, 0)
draw_vertex_texture(xx, yy + h, 0, 1)
draw_vertex_texture(xx + w, yy + h, 1, 1)

draw_primitive_end()

shader_reset()
shader_texture = 0