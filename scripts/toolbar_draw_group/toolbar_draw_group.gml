/// toolbar_draw_group(rows)
/// @arg rows

if (dx = content_x)
    return 0

if (toolbar_rows > argument0)
{
    dx = content_x
    dy += 30
}
else if (toolbar_location = "top" || toolbar_location = "bottom")
    dx += 20
