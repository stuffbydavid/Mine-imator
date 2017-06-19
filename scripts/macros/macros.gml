/// macros()

// Debug
#macro dev_mode						true
#macro dev_mode_debug_keyframes		false
#macro dev_mode_debug_schematics	false

// Versions
#macro mineimator_version			"1.1.0"
#macro mineimator_version_extra		""
#macro mineimator_version_date		"2017"
#macro gm_runtime					"2.0.6.96"
#macro minecraft_version			"1.12"

// Minecraft version format
#macro minecraft_version_1			1
#macro minecraft_version_format		minecraft_version_1

// Directories
#macro file_directory			game_save_id
#macro data_directory			working_directory + "Data\\"
#macro projects_directory		working_directory + "Projects\\"
#macro schematics_directory		working_directory + "Schematics\\"
#macro skins_directory			working_directory + "Skins\\"
#macro particles_directory		working_directory + "Particles\\"
#macro languages_directory		data_directory + "Languages\\"
#macro versions_directory		data_directory + "Versions\\"
#macro minecraft_version_file	versions_directory + minecraft_version + ".mcversion"

// Files
#macro language_file			languages_directory + "english.milang"
#macro import_file				data_directory + "import.exe"
#macro settings_file			data_directory + "settings.file"
#macro recent_file				data_directory + "recent.file"
#macro closed_file				data_directory + "alerts.file"
#macro key_file					data_directory + "key.file"
#macro log_previous_file		file_directory + "log_previous.txt"
#macro log_file					file_directory + "log.txt"
#macro temp_file				file_directory + "tmp.file"
#macro download_file			file_directory + "download.png"
#macro unzip_directory			file_directory + "unzip\\"

// Minecraft structure
#macro minecraft_directory		unzip_directory + "assets\\minecraft\\"
#macro models_directory			minecraft_directory + "models\\"
#macro blockstates_directory	minecraft_directory + "blockstates\\"
#macro textures_directory		minecraft_directory + "textures\\"
#macro character_directory		models_directory + "character\\"
#macro special_block_directory	models_directory + "special_block\\"
#macro block_directory			models_directory + "block\\"
#macro loops_directory			character_directory + "loops\\"

// Links
#macro link_skins			"http://skins.minecraft.net/MinecraftSkins/"
#macro link_directx			"https://www.microsoft.com/en-us/download/details.aspx?DisplayLang=en&id=35" // TODO
#macro link_download		"http://www.mineimator.com"
#macro link_upgrade			"http://www.mineimator.com/upgrade"
#macro link_news			"http://www.mineimator.com/news.php?version=" + mineimator_version
#macro link_forums			"http://www.mineimatorforums.com"
#macro link_forums_bugs		"http://www.mineimatorforums.com/index.php?/forum/51-mine-imator-issues-and-bugs/"
#macro link_mojang			"http://www.mojang.com"
#macro link_david			"http://www.stuffbydavid.com"

// Audio
#macro sample_rate			44100
#macro sample_size			4
#macro sample_max			32767
#macro sample_avg_per_sec	100

// Interface
#macro glow_alpha			0.75
#macro shadow_size			5
#macro shadow_alpha			0.1

// Values
#macro null					noone
#macro no_limit				100000000

// World
#macro block_size			16
#macro item_size			16
#macro world_size			30000

// Textures
#macro block_sheet_width		32
#macro block_sheet_height		16
#macro block_sheet_ani_width	32
#macro block_sheet_ani_height	1
#macro block_sheet_ani_frames	64
#macro item_sheet_width			32
#macro item_sheet_height		16

// Index
#macro X 0
#macro Y 1
#macro Z 2
#macro W 3
#macro MATX 12
#macro MATY 13
#macro MATZ 14
#macro IDENTITY matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

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



// TODO replace with enums

#macro project_01			1
#macro project_02			2
#macro project_05			3
#macro project_06			4
#macro project_07demo		5
#macro project_100demo2		6
#macro project_100demo3		7
#macro project_100demo4		8
#macro project_100debug		9
#macro project_100			10
#macro project_105			11
#macro project_105_2		12
#macro project_106			13
#macro project_106_2		14
#macro project_format		project_106_2

#macro settings_100demo4	0
#macro settings_100demo5	1
#macro settings_100			2
#macro settings_103			3
#macro settings_106			4
#macro settings_106_2		5
#macro settings_106_3		6
#macro settings_110			7
#macro settings_format		settings_110

#macro POSITION 0
#macro ROTATION 1
#macro SCALE 2
#macro BEND 3
#macro COLOR 4
#macro PARTICLES 5
#macro LIGHT 6
#macro SPOTLIGHT 7
#macro CAMERA 8
#macro BACKGROUND 9
#macro TEXTURE 10
#macro SOUND 11
#macro KEYFRAME 12
#macro ROTPOINT 13
#macro HIERARCHY 14
#macro GRAPHICS 15
#macro AUDIO 16
#macro value_types 17

#macro XPOS 0
#macro YPOS 1
#macro ZPOS 2
#macro XROT 3
#macro YROT 4
#macro ZROT 5
#macro XSCA 6
#macro YSCA 7
#macro ZSCA 8
#macro BENDANGLE 9
#macro ALPHA 10
#macro RGBADD 11
#macro RGBSUB 12
#macro RGBMUL 13
#macro HSBADD 14
#macro HSBSUB 15
#macro HSBMUL 16
#macro MIXCOLOR 17
#macro MIXPERCENT 18
#macro BRIGHTNESS 19
#macro SPAWN 20
#macro ATTRACTOR 21
#macro FORCE 22
#macro LIGHTCOLOR 23
#macro LIGHTRANGE 24
#macro LIGHTFADESIZE 25
#macro LIGHTSPOTRADIUS 26
#macro LIGHTSPOTSHARPNESS 27
#macro CAMFOV 28
#macro CAMROTATE 29
#macro CAMROTATEDISTANCE 30
#macro CAMROTATEXYANGLE 31
#macro CAMROTATEZANGLE 32
#macro CAMDOF 33
#macro CAMDOFDEPTH 34
#macro CAMDOFRANGE 35
#macro CAMDOFFADESIZE 36
#macro CAMSIZEUSEPROJECT 37
#macro CAMSIZEKEEPASPECTRATIO 38
#macro CAMWIDTH 39
#macro CAMHEIGHT 40
#macro BGSKYMOONPHASE 41
#macro BGSKYTIME 42
#macro BGSKYROTATION 43
#macro BGSKYCLOUDSSPEED 44
#macro BGSKYCOLOR 45
#macro BGSKYCLOUDSCOLOR 46
#macro BGSUNLIGHTCOLOR 47
#macro BGAMBIENTCOLOR 48
#macro BGNIGHTCOLOR 49
#macro BGFOGCOLOR 50
#macro BGFOGDISTANCE 51
#macro BGFOGSIZE 52
#macro BGFOGHEIGHT 53
#macro BGWINDSPEED 54
#macro BGWINDSTRENGTH 55
#macro BGTEXTUREANISPEED 56
#macro TEXTUREOBJ 57
#macro SOUNDOBJ 58
#macro SOUNDVOLUME 59
#macro SOUNDSTART 60
#macro SOUNDEND 61
#macro VISIBLE 62
#macro TRANSITION 63
#macro values 64