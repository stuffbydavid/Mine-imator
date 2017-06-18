/// draw_label(string, x, y, [halign, valign, [color, alpha, [font]]])
/// @arg string
/// @arg x
/// @arg y
/// @arg halign
/// @arg valign
/// @arg [color
/// @arg alpha
/// @arg [font]]

var str, xx, yy, halign, valign, color, alpha, font;
var oldcolor, oldalpha;
str = argument[0]
xx = argument[1]
yy = argument[2]

if (xx + string_width(str) < content_x || 
	xx > content_x + content_width || 
	yy + string_height(str) < content_y || 
	yy > content_y + content_height)
    return 0

if (argument_count > 3)
{
    halign = argument[3]
    valign = argument[4]
    draw_set_halign(halign)
    draw_set_valign(valign)
}

if (argument_count > 5)
{
    color = argument[5]
    alpha = argument[6]
    if (color != null)
	{
        oldcolor = draw_get_color()
        draw_set_color(color)
    }
    if (alpha < 1)
	{
        oldalpha = draw_get_alpha()
        draw_set_alpha(oldalpha * alpha)
    }
}

if (argument_count > 7)
{
    font = argument[7]
    draw_set_font(font)
}

draw_text(xx, yy, str)

if (argument_count > 3)
{
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

if (argument_count > 5)
{
    if (color != null)
        draw_set_color(oldcolor)
    if (alpha < 1)
        draw_set_alpha(oldalpha)
}

if (argument_count > 7)
    draw_set_font(setting_font)
