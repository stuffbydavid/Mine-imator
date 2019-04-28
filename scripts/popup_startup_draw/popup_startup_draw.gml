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
draw_label(text_get("startupversion", text_get((trial_version ? "startuptrial" : "startupfull")), mineimator_version, mineimator_version_date), dx, dy)
dy += string_height(" ")

// David
var creditsx = dx;
credittext = text_get("startupcredits1")
creditname = "David Norgren"
draw_label(credittext, dx, dy)
dx += string_width(credittext)
if (draw_link("startupcredits1", creditname, dx, dy) && mouse_left_pressed)
	open_url(link_david)
dx += string_width(creditname)

// Minecraft
credittext = text_get("startupcredits2")
creditname = "Minecraft"
draw_label(credittext, dx, dy)
dx += string_width(credittext)
if (draw_link("startupcredits2", creditname, dx, dy) && mouse_left_pressed)
	open_url(link_minecraft)
dx += string_width(creditname)

dx = creditsx
dy += string_height(" ")
draw_label(text_get("startupcredits3", "David", "Nimi", "Marvin", "Voxy"), dx, dy)

// Buttons
dx = content_x
dy = content_y + 160 + 70
dw = 200
dh = 48

// New
if (draw_button_normal("startupnewproject", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.NEW_PROJECT))
{
	popup_newproject_clear()
	popup_switch(popup_newproject)
}
dy += dh + 8

// Open
if (draw_button_normal("startupopenproject", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.OPEN_PROJECT))
	project_load()
dy += dh + 8

// Upgrade
if (trial_version)
{
	if (draw_button_normal("startupupgrade", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.UPGRADE_SMALL))
		popup_switch(popup_upgrade)
	dy += dh + 8
}
	
// Tutorials
if (draw_button_normal("startuptutorials", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.HELP_SMALL))
	action_toolbar_tutorials()
dy += dh + 8

// Website
dh = 32
dw = floor(dw / 2-5)
if (draw_button_normal("startupwebsite", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.WEBSITE_SMALL))
	action_toolbar_website()

// Forums
dx += dw + 10
if (draw_button_normal("startupforums", dx, dy, dw, dh, e_button.TEXT, false, true, true, icons.FORUMS_SMALL))
	action_toolbar_forums()
   
// Recent
dx = content_x + 200 + 16
dy = content_y + 160 + 70
dw = content_width - (dx - content_x)
dh = content_height - (dy - content_y)
draw_label(text_get("startuprecent") + ":", dx, dy - 22)

draw_recent(dx, dy, dw, dh, popup_startup.recent_scroll)
