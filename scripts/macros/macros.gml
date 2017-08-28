/// macros()

// Debug
#macro dev_mode						true
#macro dev_mode_debug_schematics	false

// Versions
#macro mineimator_version			"1.1.0"
#macro mineimator_version_extra		""
#macro mineimator_version_date		"2017"
#macro gm_runtime					"2.0.7.110"
#macro minecraft_version			"1.12"

// File formats
#macro project_format				e_project.FORMAT_110
#macro settings_format				e_settings.FORMAT_110
#macro minecraft_assets_format		e_minecraft_assets.FORMAT_110

// Directories
#macro file_directory			game_save_id
#macro data_directory			working_directory + "Data\\"
#macro projects_directory		working_directory + "Projects\\"
#macro schematics_directory		working_directory + "Schematics\\"
#macro skins_directory			working_directory + "Skins\\"
#macro particles_directory		working_directory + "Particles\\"
#macro languages_directory		data_directory + "Languages\\"
#macro minecraft_directory		data_directory + "Minecraft\\"

// Files
#macro minecraft_assets_file	minecraft_directory + minecraft_version + ".mcassets"
#macro language_file			languages_directory + "english.milang"
#macro import_file				data_directory + "import.exe"
#macro settings_file			data_directory + "settings.midata"
#macro legacy_file				data_directory + "legacy.midata"
#macro recent_file				data_directory + "recent.midata"
#macro closed_file				data_directory + "alerts.midata"
#macro key_file					data_directory + "key.midata"
#macro log_previous_file		file_directory + "log_previous.txt"
#macro log_file					file_directory + "log.txt"
#macro temp_file				file_directory + "tmp.file"
#macro download_image_file		file_directory + "download.png"
#macro unzip_directory			file_directory + "unzip\\"

// Minecraft structure
#macro assets_directory			unzip_directory + "assets\\minecraft\\"
#macro models_directory			assets_directory + "models\\"
#macro blockstates_directory	assets_directory + "blockstates\\"
#macro textures_directory		assets_directory + "textures\\"
#macro character_directory		models_directory + "character\\"
#macro special_block_directory	models_directory + "special_block\\"
#macro block_directory			models_directory + "block\\"
#macro loops_directory			character_directory + "loops\\"

// Links
#macro link_skins				"http://skins.minecraft.net/MinecraftSkins/"
#macro link_directx				"https://www.microsoft.com/en-us/download/details.aspx?DisplayLang=en&id=35" // TODO
#macro link_download			"http://www.mineimator.com"
#macro link_upgrade				"http://www.mineimator.com/upgrade"
#macro link_news				"http://www.mineimator.com/news.php?version=" + mineimator_version
#macro link_forums				"http://www.mineimatorforums.com"
#macro link_forums_bugs			"http://www.mineimatorforums.com/index.php?/forum/51-mine-imator-issues-and-bugs/"
#macro link_mojang				"http://www.mojang.com"
#macro link_david				"http://www.stuffbydavid.com"

// Audio
#macro sample_rate				44100
#macro sample_size				4
#macro sample_max				32767
#macro sample_avg_per_sec		100

// Interface
#macro glow_alpha				0.75
#macro shadow_size				5
#macro shadow_alpha				0.1

// Values
#macro null						noone
#macro no_limit					100000000

// World
#macro block_size				16
#macro item_size				16
#macro world_size				30000

// Textures
#macro block_sheet_width		32
#macro block_sheet_height		16
#macro block_sheet_ani_width	32
#macro block_sheet_ani_height	1
#macro block_sheet_ani_frames	64
#macro item_sheet_width			32
#macro item_sheet_height		16

// Vectors and matrices
#macro X				0
#macro Y				1
#macro Z				2
#macro W				3
#macro MAT_X			12
#macro MAT_Y			13
#macro MAT_Z			14
#macro MAT_IDENTITY		matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

// Colors
#macro c_main				make_color_rgb(200, 200, 200)
#macro c_secondary			make_color_rgb(67, 103, 163)
#macro c_text				make_color_rgb(10, 10, 10)
#macro c_tips				make_color_rgb(40, 40, 40)
#macro c_highlight			make_color_rgb(132, 159, 204)
#macro c_alerts				make_color_rgb(240, 255, 159)
#macro c_controls			make_color_rgb(40, 40, 40)
#macro c_sky				make_color_rgb(145, 185, 255)
#macro c_night				make_color_rgb(14, 14, 24)
#macro c_clouds_bottom		make_color_rgb(174, 181, 193)
#macro c_clouds_top			make_color_rgb(255, 255, 255)
#macro c_clouds_sideslight	make_color_rgb(215, 222, 234)
#macro c_clouds_sidesdark	make_color_rgb(194, 201, 215)