/// interface_update()
/// @desc Updates interface colors based on selected theme

var theme = setting_theme;

// Accent color(s)

if (setting_accent = 9)
	c_accent = setting_accent_custom
else
	c_accent = theme.accent_list[setting_accent]

interface_update_accent()

c_text_main = theme.text_main
c_text_secondary = theme.text_secondary
c_text_tertiary = theme.text_tertiary
c_border = theme.border
c_overlay = theme.overlay
c_button_text = theme.button_text
a_button_text = theme.button_text_alpha

c_background = theme.background
c_background_secondary = theme.background_secondary
c_viewport_top = theme.viewport_top
c_viewport_bottom = theme.viewport_bottom
c_error = theme.red_error
c_warning = theme.yellow_warning
c_success = theme.green_success
c_axisred = theme.red
c_axisgreen = theme.green
c_axisblue = theme.blue
c_bend = theme.pink

c_axiscyan = theme.cyan
c_axisyellow = theme.yellow
c_axismagenta = theme.magenta

update_interface_wait = false
