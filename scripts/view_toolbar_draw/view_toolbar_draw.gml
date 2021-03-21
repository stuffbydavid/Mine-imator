/// view_toolbar_draw(view, x, y)
/// @arg view
/// @arg x
/// @arg y

var view, xx, yy, width, height;
var starty, padding;
view = argument0
xx = argument1
yy = argument2
width = 32
height = view.toolbar_height

starty = yy
padding = 4

if (yy + height > content_y + content_height)
{
	view.toolbar_mouseon = false
	return 0
}

microani_prefix = string(view)

if (app_mouse_box(xx, yy, width, height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon))
	view.toolbar_mouseon = true
else
	view.toolbar_mouseon = false

if (view.toolbar_mouseon)
	content_mouseon = true

draw_box(xx, yy, width, height, false, c_level_top, 1)
draw_outline(xx, yy, width, height, 1, c_border, a_border, true)

xx += 4
yy += 4

tip_force_right = true

// Workbench
bench_settings.posy = yy - 4
bench_settings.posx = xx + 28
	
if (draw_button_icon("viewworkbench", xx, yy, 24, 24, (bench_show_ani_type = "show" || bench_show_ani = 1), icons.WORKBENCH, null, false, "viewworkbenchtip"))
{
	bench_hover_ani = 0
	bench_click_ani = 1
	bench_show_ani_type = "show"
	window_busy = "bench"
}
yy += 24 + padding

draw_divide(xx, yy, 24)
yy += 1 + padding

// Select tool
tip_set_keybind(e_keybind.TOOL_SELECT)
if (draw_button_icon("viewtoolselect", xx, yy, 24, 24, setting_tool = e_view_tool.SELECT, icons.TOOL_SELECT, null, false, "viewtoolselecttip"))
	setting_tool = e_view_tool.SELECT
yy += 24 + padding

// Position tool
tip_set_keybind(e_keybind.TOOL_MOVE)
if (draw_button_icon("viewtoolmove", xx, yy, 24, 24, setting_tool = e_view_tool.MOVE, icons.TOOL_MOVE, null, false, "viewtoolmovetip"))
	setting_tool = e_view_tool.MOVE
yy += 24 + padding

// Rotation tool
tip_set_keybind(e_keybind.TOOL_ROTATE)
if (draw_button_icon("viewtoolrotate", xx, yy, 24, 24, setting_tool = e_view_tool.ROTATE, icons.TOOL_ROTATE, null, false, "viewtoolrotatetip"))
	setting_tool = e_view_tool.ROTATE
yy += 24 + padding

// Scale tool
tip_set_keybind(e_keybind.TOOL_SCALE)
if (draw_button_icon("viewtoolscale", xx, yy, 24, 24, setting_tool = e_view_tool.SCALE, icons.TOOL_SCALE, null, false, "viewtoolscaletip"))
	setting_tool = e_view_tool.SCALE
yy += 24 + padding

// Bend tool
tip_set_keybind(e_keybind.TOOL_BEND)
if (draw_button_icon("viewtoolbend", xx, yy, 24, 24, setting_tool = e_view_tool.BEND, icons.TOOL_BEND, null, false, "viewtoolbendtip"))
	setting_tool = e_view_tool.BEND
yy += 24 + padding

// Transform tool
tip_set_keybind(e_keybind.TOOL_TRANSFORM)
if (draw_button_icon("viewtooltransform", xx, yy, 24, 24, setting_tool = e_view_tool.TRANSFORM, icons.TOOL_TRANSFORM, null, false, "viewtooltransformtip"))
	setting_tool = e_view_tool.TRANSFORM
yy += 24 + padding

tip_force_right = false

view.toolbar_height = yy - starty
microani_prefix = ""
