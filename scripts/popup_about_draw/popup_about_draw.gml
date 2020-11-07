/// popup_about_draw()

// Header
draw_box(dx, dy, dw, 128, false, c_overlay, a_overlay)

// Close
if (draw_button_icon("aboutclose", dx + dw - 12 - 28, dy + 8, 28, 28, false, icons.CLOSE, null, false))
	popup_close()

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
draw_button_text(version, textx, dy + 98, open_url, "https://www.mineimator.com", "https://www.mineimator.com")
textx += string_width(version)

draw_label(text_get("aboutreleasedate", mineimator_version_date), textx, dy + 98, fa_left, fa_bottom, c_text_secondary, a_text_secondary)

// Minecraft credits
var mctext, mctextx;
mctext = string_width(text_get("aboutminecraftpre") + text_get("aboutminecraft"))
mctextx = floor(content_x + (content_width/2) - (mctext/2))
draw_label(text_get("aboutminecraftpre"), mctextx, dy + 98 + 19, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
mctextx += string_width(text_get("aboutminecraftpre"))
draw_button_text(text_get("aboutminecraft"), mctextx, dy + 98 + 19, open_url, "https://www.minecraft.net", "https://www.minecraft.net")

dy += 128 + 48
dx = content_x + 64

// Created by
dy += 12
draw_label(text_get("aboutcreatedby"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 26
draw_button_text("David Norgren", dx, dy, open_url, "https://www.stuffbydavid.com", "https://www.stuffbydavid.com", font_emphasis)

// Development
dy += 34
draw_label(text_get("aboutdevelopment"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 26
draw_button_text("David", dx, dy, open_url, "https://twitter.com/stuffbydavidn", "https://twitter.com/stuffbydavidn", font_emphasis)
dy += 19
draw_button_text("Nimi", dx, dy, open_url, "https://twitter.com/NimiKitamura", "https://twitter.com/NimiKitamura", font_emphasis)
dy += 19
draw_button_text("Marvin", dx, dy, open_url, "https://twitter.com/MineToBlend", "https://twitter.com/MineToBlend", font_emphasis)

// UI/Branding
dy += 34
draw_label(text_get("aboutuibranding"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 26
draw_button_text("Voxy", dx, dy, open_url, "https://twitter.com/voxybuns", "https://twitter.com/voxybuns", font_emphasis)

dx += 130 + 24
dy = content_y + 176

// Beta testing
dy += 12
draw_label(text_get("aboutbetatesting"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 26
draw_label("Espresso", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
dy += 19
draw_label("Hozq", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
dy += 19
draw_label("KeepOnChucking", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
dy += 19
draw_label("Mr.Banders", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
dy += 19
draw_label("SoundsDotZip", dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)