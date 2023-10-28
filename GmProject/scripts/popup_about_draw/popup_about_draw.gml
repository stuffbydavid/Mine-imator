/// popup_about_draw()

function popup_about_draw()
{
	// Header
	draw_box(dx, dy, dw, 128, false, c_overlay, a_overlay)
	
	// Logo
	gpu_set_tex_filter(true)
	draw_sprite_ext(spr_logo, 0, dx + dw / 2, dy + 54, .75, .75, 0, c_white, draw_get_alpha())
	gpu_set_tex_filter(false)
	
	// Program info
	draw_set_font(font_value)
	
	var text, width, textx;
	text = text_get("aboutversion", mineimator_version_full) + text_get("aboutreleasedate", mineimator_version_date)
	width = string_width(text)
	textx = floor(dx + dw/2 - width/2)
	
	var version = text_get("aboutversion", mineimator_version_full) + (trial_version ? " " + text_get("startuptrial") : "");
	draw_button_text(version, textx, dy + 98, popup_open_url, link_website, link_website)
	textx += string_width(version)
	
	draw_label(text_get("aboutreleasedate", mineimator_version_date), textx, dy + 98, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	
	// Minecraft credits
	var mctext, mctextx;
	mctext = string_width(text_get("aboutminecraftpre") + text_get("aboutminecraft"))
	mctextx = floor(content_x + (content_width/2) - (mctext/2))
	draw_label(text_get("aboutminecraftpre"), mctextx, dy + 98 + 19, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	mctextx += string_width(text_get("aboutminecraftpre"))
	draw_button_text(text_get("aboutminecraft"), mctextx, dy + 98 + 19, popup_open_url, link_minecraft, link_minecraft)
	
	dy += 128 + 48
	dx = content_x + 64
	
	// Button links
	var buttonx, buttony;
	buttonx = content_x + 12
	buttony = content_y + content_height - (12 + 28);
	
	if (draw_button_icon("aboutsite", buttonx, buttony, 24, 24, false, icons.WORLD, null, false, "aboutsite"))
		open_url(link_website)
	
	if (draw_button_icon("aboutforums", buttonx + (30), buttony, 24, 24, false, icons.COMMENTS, null, false, "aboutforums"))
		open_url(link_forums)
	
	if (draw_button_icon("abouttwitter", buttonx + (30 * 2), buttony, 24, 24, false, icons.TWITTER, null, false, "abouttwitter"))
		open_url(link_twitter)
	
	if (draw_button_icon("aboutdiscord", buttonx + (30 * 3), buttony, 24, 24, false, icons.DISCORD, null, false, "aboutdiscord"))
		open_url(link_discord)
	
	if (trial_version)
	{
		if (draw_button_label("aboutupgrade", content_x + content_width - 13, content_y + content_height - (12 + 32), null, icons.KEY, e_button.PRIMARY, null, fa_right))
		{
			popup_switch(popup_upgrade)
			popup_upgrade.page = 0
		}
	}
	else
	{
		if (draw_button_label("aboutdonate", content_x + content_width - 13, content_y + content_height - (12 + 32), null, icons.DONATE, e_button.PRIMARY, null, fa_right))
			open_url(link_donate)
	}
	
	// Created by
	dy += 12
	draw_label(text_get("aboutcreatedby"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 26
	draw_button_text("David Andrei", dx, dy, popup_open_url, link_david, link_david, font_label)
	
	// Development
	dy += 34
	draw_label(text_get("aboutdevelopment"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 26
	draw_button_text("David", dx, dy, popup_open_url, link_david, link_david, font_label)
	dy += 19
	draw_label("Nimi", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	dy += 19
	draw_label("Marvin", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	dy += 19
	draw_label("mbanders", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	// UI/Branding
	dy += 34
	draw_label(text_get("aboutuibranding"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 26
	draw_label("Voxy", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	dx += 130 + 24
	dy = content_y + 176
	
	// Beta testing
	var list = [
		"9redwoods",
		"Alpha Toostrr",
		"AnxiousCynic",
		"Cade [CaZaKoJa]",
		"Hozq",
		"Jnick",
		"Jossamations",
		"KeepOnChucking",
		"Rollo",
		"SKIBBZ",
		"SoundsDotZip",
		"Swooplezz",
		"UpgradedMoon",
		"Vash",
		"__Mine__"
	]
	
	dy += 12
	draw_label(text_get("aboutbetatesting"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 26
	
	for (var i = 0; i < array_length(list); i++)
	{
		draw_label(list[i], dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
		dy += 19
		
		if (i = 7)
		{
			dx += 130 + 24
			dy = content_y + 176 + 12 + 26
		}
	}
}