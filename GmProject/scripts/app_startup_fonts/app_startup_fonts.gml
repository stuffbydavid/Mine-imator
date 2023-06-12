/// app_startup_fonts()

function app_startup_fonts()
{
	font_subheading = font_add(fonts_directory + "rubik_medium.ttf", 8.5, false, false, 32, 1024)
	font_label = font_add(fonts_directory + "noto_bold.ttf", 9, false, false, 32, 1024)
	font_value = font_add(fonts_directory + "noto_regular.ttf", 9, false, false, 32, 1024)
	font_digits = font_add(fonts_directory + "notomono_regular.ttf", 9, false, false, 32, 1024)
	font_caption = font_add(fonts_directory + "noto_regular.ttf", 8, false, false, 32, 1024)
	font_button = font_add(fonts_directory + "rubik_medium.ttf", 9.5, false, false, 32, 1024)
	
	// Special-case fonts
	font_upgrade = font_add(fonts_directory + "noto_regular.ttf", 18, false, false, 32, 1024)
	font_heading = font_add(fonts_directory + "rubik_medium.ttf", 10, false, false, 32, 1024)
	font_body_big = font_add(fonts_directory + "noto_regular.ttf", 12, false, false, 32, 1024)
	font_heading_big = font_add(fonts_directory + "rubik_medium.ttf", 13, false, false, 32, 1024)
}
