/// draw_texture_part(texture, x, y, left, top, width, height, [xscale, yscale, [color, alpha]])
/// @arg texture
/// @arg x
/// @arg y
/// @arg left
/// @arg top
/// @arg width
/// @arg height
/// @arg [xscale
/// @arg yscale
/// @arg [color
/// @arg alpha]]

var tex, xx, yy, left, top, w, h, xsca, ysca, color, alpha;
var tw, th;
tex = argument[0]
xx = argument[1]
yy = argument[2]
left = argument[3]
top = argument[4]
w = argument[5]
h = argument[6]

if (argument_count > 7)
{
    xsca = argument[7]
    ysca = argument[8]
}
else
{
    xsca = 1
    ysca = 1
}

if (argument_count > 9)
{
    color = argument[9]
    alpha = draw_get_alpha() * argument[10]
}
else
{
    color = c_white
    alpha = draw_get_alpha()
}

tw = texture_width(tex)
th = texture_height(tex)

shader_texture = tex
shader_draw_texture_set()
	
draw_primitive_begin(pr_trianglestrip)

draw_vertex_texture_color(xx, yy, left / tw, top / th, color, alpha)
draw_vertex_texture_color(xx + w * xsca, yy, (left + w) / tw, top / th, color, alpha)
draw_vertex_texture_color(xx, yy + h * ysca, left / tw, (top + h) / th, color, alpha)
draw_vertex_texture_color(xx + w * xsca, yy + h * ysca, (left + w) / tw, (top + h) / th, color, alpha)

draw_primitive_end()

texture_set_stage(0, 0)
shader_reset()
shader_texture = 0