/// popup_startup_draw()
/// @desc Startup/welcome screen.

var credittext, creditname;

// Logo
dx = content_x + content_width / 2 - 550 / 2
dy = content_y + 10
draw_image(spr_logo, 0, dx, dy)

// Logo text
dx += 175
dy += 115
draw_label(text_get("startupversion", text_get(test(trial_version, "startuptrial", "startupfull")), mineimator_version, mineimator_version_date), dx, dy)
dy += string_height(" ")

// David
credittext = text_get("startupcredits1")
creditname = "David Norgren"
draw_label(credittext, dx, dy)
dx += string_width(credittext)
if (draw_link("startupcredits1", creditname, dx, dy) && mouse_left_pressed)
	open_url(link_david)
dx += string_width(creditname)

// Mojang
credittext = text_get("startupcredits2")
creditname = "Mojang"
draw_label(credittext, dx, dy)
dx += string_width(credittext)
if (draw_link("startupcredits2", creditname, dx, dy) && mouse_left_pressed)
	open_url(link_mojang)
dx += string_width(creditname)

// Buttons
dx = content_x
dy = content_y + 160 + 70
dw = 200
dh = 48

// New
if (draw_button_normal("startupnewproject", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.newproject))
{
	popup_newproject_clear()
	popup_switch(popup_newproject)
}
dy += dh + 8

// Open
if (draw_button_normal("startupopenproject", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.openproject))
	project_open("")
dy += dh + 8

// Upgrade
if (trial_version)
{
	if (draw_button_normal("startupupgrade", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.upgradesmall))
		popup_switch(popup_upgrade)
	dy += dh + 8
}

// Website
dw = floor(dw / 2-5)
dh = 32
if (draw_button_normal("startupwebsite", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.websitesmall))
	action_toolbar_website()

// Forums
dx += dw + 10
if (draw_button_normal("startupforums", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.forumssmall))
	action_toolbar_forums()
   
// Recent
dx = content_x + 200 + 16
dy = content_y + 160 + 70
dw = content_width - (dx - content_x)
dh = content_height - (dy - content_y)
draw_label(text_get("startuprecent") + ":", dx, dy - 22)

draw_recent(dx, dy, dw, dh, popup_startup.recent_scroll)
