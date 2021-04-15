/// draw_pattern(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var xx, yy, w, h, ypos, pattern;
xx = argument0
yy = argument1
w = argument2
h = argument3
pattern = (setting_theme = theme_light ? 0 : 1)

// Left
ypos = yy
while (ypos < yy + h)
{
	draw_sprite_ext(spr_pattern_left, pattern, xx, ypos, 80, 80, 0, c_white, 1)
	ypos += (sprite_get_height(spr_pattern_left) * 80)
}

// Right
ypos = yy
while (ypos < yy + h)
{
	draw_sprite_ext(spr_pattern_right, pattern, xx + w, ypos, 80, 80, 0, c_white, 1)
	ypos += (sprite_get_height(spr_pattern_right) * 80)
}