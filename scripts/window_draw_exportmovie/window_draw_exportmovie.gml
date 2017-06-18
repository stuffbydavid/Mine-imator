/// window_draw_exportmovie()

var totalframes, perc;
var framex, framey, framew, frameh;
var timeleftsecs, timeleftmins, timelefthours, timeleftstr;

// Update rendering
if (!action_toolbar_exportmovie_update())
    return 0

// Set dimensions
totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.frame_rate)
perc = exportmovie_frame / totalframes

content_width = floor(window_width * 0.8)
content_height = min(500, floor(window_height * 0.5))
content_x = floor(window_width / 2-content_width / 2)
content_y = floor(window_height / 2-content_height / 2)

// Background
draw_clear(setting_color_interface)

// Frame
draw_label(text_get("exportmovieframe", string(exportmovie_frame), string(totalframes)), content_x + content_width / 2, content_y, fa_center, fa_top, null, 1, setting_font_big)

// Current surface
framew = 600
frameh = max(10, content_height - 150)
framex = content_x + content_width / 2-framew / 2
framey = content_y + 30

draw_surface_box(exportmovie_surface, framex, framey, framew, frameh)
    
// Time left
timeleftsecs = ceil((exportmovie_start + (current_time - exportmovie_start) / perc - current_time) / 1000)
timeleftmins = timeleftsecs div 60
timelefthours = timeleftmins div 60
timeleftsecs = timeleftsecs mod 60
timeleftmins = timeleftmins mod 60

timeleftstr = ""
if (timelefthours > 0)
    timeleftstr += text_get(test(timelefthours = 1, "exportmovietimelefthour", "exportmovietimelefthours"), string(timelefthours)) + ", "
if (timeleftmins > 0)
    timeleftstr += text_get(test(timeleftmins = 1, "exportmovietimeleftminute", "exportmovietimeleftminutes"), string(timeleftmins)) + " " + text_get("exportmovietimeleftand") + " "
timeleftstr += text_get(test(timeleftsecs = 1, "exportmovietimeleftsecond", "exportmovietimeleftseconds"), string(timeleftsecs))

draw_label(text_get("exportmovietimeleft", timeleftstr), content_x + content_width / 2, content_y + content_height - 80, fa_center, fa_middle, null, 1, setting_font_big)

// Bar
draw_loading_bar(content_x, content_y + content_height - 32, content_width, 32, perc, text_get("exportmovieloading", string(floor(perc * 100))))

// Stop
content_height += 32
draw_label(text_get("exportmoviestop"), content_x + content_width / 2, content_y + content_height - 24, fa_center, fa_top)
