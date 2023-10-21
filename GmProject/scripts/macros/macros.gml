/// macros()
/// @desc Defines constants used in the project.

function macros()
{
	// Debug
	#macro dev_mode						false
	#macro dev_mode_skip_blocks			dev_mode && true
	#macro dev_mode_debug_schematics	dev_mode && true
	#macro dev_mode_debug_names			dev_mode && true
	#macro dev_mode_debug_saveid		dev_mode && true
	#macro dev_mode_debug_unused		dev_mode && true
	#macro dev_mode_project				file_directory + "//dev_project//dev_project.miproject"
	#macro dev_mode_full				dev_mode && false
	#macro dev_mode_advanced			dev_mode && true
	#macro dev_mode_show_bones			dev_mode && true
	#macro dev_mode_skip_tangents		dev_mode && true
	#macro dev_mode_check_assets		dev_mode && true
	#macro dev_mode_name_translation_message " is not defined in the translation, the key will be formatted"
	
	// Versions
	#macro mineimator_version			"2.0.1"		// Base Mine-imator version
	#macro mineimator_version_sub		""			// Mod name and version (e.g. "Community Build 1.0.0")
	#macro mineimator_version_extra		"Alpha 2"	// Additional suffix (e.g. "Alpha 1" or "Pre-Release 2")
	#macro mineimator_version_full		(mineimator_version + ((mineimator_version_sub != "") ? " " + mineimator_version_sub : "") + ((mineimator_version_extra != "") ? " (" + mineimator_version_extra + ")" : ""))
	#macro mineimator_version_date		"2023.10.21"
	#macro minecraft_version			"1.20.2"
	#macro gm_runtime					GM_runtime_version
	
	// File formats
	#macro project_format				e_project.FORMAT_200_PRE_5
	#macro settings_format				e_settings.FORMAT_200
	#macro minecraft_assets_format		e_minecraft_assets.FORMAT_200
	
	// Directories
	#macro file_directory				game_save_id
	#macro data_directory				working_directory + "Data/"
	#macro projects_directory			working_directory + "Projects/"
	#macro schematics_directory			working_directory + "Schematics/"
	#macro particles_directory			working_directory + "Particles/"
	#macro fonts_directory				data_directory + "Fonts/"
	#macro languages_directory			data_directory + "Languages/"
	#macro minecraft_directory			data_directory + "Minecraft/"
	#macro render_directory				data_directory + "Render/"
	#macro splash_directory				data_directory + "Splashes/"
	
	// Files
	#macro language_file				languages_directory + "english.milanguage"
	#macro languages_file				data_directory + "languages.midata"
	#macro legacy_file					data_directory + "legacy.midata"
	#macro settings_file				user_directory_get() + "settings.midata"
	#macro recent_file					user_directory_get() + "recent.midata"
	#macro key_file						user_directory_get() + "key.midata"
	#macro log_file						user_directory_get() + "log.txt"
	#macro temp_file					file_directory + "tmp.file"
	#macro temp_image					file_directory + "tmp.png"
	#macro download_image_file			file_directory + "download.png"
	#macro unzip_directory				file_directory + "unzip/"
	#macro render_default				"performance"
	#macro render_default_file			render_directory + render_default + ".mirender"
	#macro asset_exts					"*.miobject;*.miframes;*.zip;*.schematic;*.miproject;*.miparticles;*.mimodel;*.png;*.jpg;*.json;*.ttf;*.mp3;*.wav;*.ogg;*.flac;*.wma;*.m4a;*.object;*.keyframes;*.particles;*.mproj;*.mani;*.blocks;*.nbt;*.dat;"
	
	// Minecraft structure
	#macro mc_file_directory			file_directory + "Minecraft_unzip/"
	#macro mc_assets_directory			"assets/minecraft/"
	#macro mc_models_directory			mc_assets_directory + "models/"
	#macro mc_blockstates_directory		mc_assets_directory + "blockstates/"
	#macro mc_textures_directory		mc_assets_directory + "textures/"
	#macro mc_character_directory		mc_models_directory + "character/"
	#macro mc_special_block_directory	mc_models_directory + "special_block/"
	#macro mc_block_directory			mc_models_directory + "block/"
	#macro mc_loops_directory			mc_character_directory + "loops/"
	
	#macro mc_pack_image_file			"pack.png"
	#macro mc_grass_image_file			mc_textures_directory + "colormap/grass.png"
	#macro mc_foliage_image_file		mc_textures_directory + "colormap/foliage.png"
	#macro mc_particles_image_file		mc_textures_directory + "particle/particles.png"
	#macro mc_explosion_image_file		mc_textures_directory + "entity/explosion.png"
	#macro mc_sun_image_file			mc_textures_directory + "environment/sun.png"
	#macro mc_moon_phases_image_file	mc_textures_directory + "environment/moon_phases.png"
	#macro mc_clouds_image_file			mc_textures_directory + "environment/clouds.png"
	#macro mc_glint_entity_file			mc_textures_directory + "misc/enchanted_glint_entity.png"
	#macro mc_glint_item_file			mc_textures_directory + "misc/enchanted_glint_item.png"
	
	// Links
	#macro link_website					"https://www.mineimator.com"
	#macro link_tutorials				"https://www.mineimator.com/tutorials2"
	#macro link_download				"https://www.mineimator.com/download"
	#macro link_upgrade					"https://www.mineimator.com/upgrade"
	#macro link_assets					"https://www.mineimator.com/assets/"
	#macro link_assets_versions			link_assets + "versions.midata"
	#macro link_news					"https://www.mineimator.com/news.php?version=" + mineimator_version + "&platform=" + string(platform_get()) + "&os=" + os_get()
	#macro link_skins					"https://www.mineimator.com/skin?username="
	#macro link_forums					"https://www.mineimatorforums.com"
	#macro link_forums_bugs				"https://www.mineimatorforums.com/index.php?/forum/51-issues-and-bugs/&do=add"
	#macro link_forums_upload			"https://www.mineimatorforums.com/index.php?/topic/10-guide-how-to-post-a-mine-imator-project/"
	#macro link_minecraft				"https://www.minecraft.net"
	#macro link_david					"https://www.stuffbydavid.com"
	#macro link_modelbench				"https://www.mineimator.com/modelbench"
	#macro link_twitter					"https://www.mineimator.com/tweets"
	#macro link_discord					"https://www.mineimator.com/discord"
	#macro link_donate					"https://www.mineimator.com/donate"
	#macro link_article_drivers			"https://www.thewindowsclub.com/how-to-update-graphics-drivers-windows"
	#macro show_modelbench_popup		true
	#macro http_ok						200
	#macro http_bad_request				400
	
	// Textures
	#macro block_sheet_width			32
	#macro block_sheet_height			32
	#macro block_sheet_ani_width		32
	#macro block_sheet_ani_height		2
	#macro block_sheet_ani_frames		80
	#macro item_sheet_width				32
	#macro item_sheet_height			32
	
	// Colors
	#macro c_controls					make_color_rgb(40, 40, 40)
	#macro c_sky						make_color_rgb(120, 167, 255)
	#macro c_clouds						make_color_rgb(255, 255, 255)
	#macro c_sunlight					make_color_rgb(255, 247, 228)
	#macro c_ambient					make_color_rgb(102, 112, 140)
	#macro c_night						make_color_rgb(14, 14, 24)
	#macro c_clouds_bottom				make_color_rgb(174, 181, 193)
	#macro c_clouds_top					make_color_rgb(255, 255, 255)
	#macro c_clouds_sideslight			make_color_rgb(215, 222, 234)
	#macro c_clouds_sidesdark			make_color_rgb(194, 201, 215)
	#macro c_plains_biome_foliage		make_color_rgb(119, 171, 47)
	#macro c_plains_biome_foliage_2		make_color_rgb(98, 168, 87)
	#macro c_plains_biome_grass			make_color_rgb(145, 189, 89)
	#macro c_plains_biome_water			make_color_rgb(62, 117, 225)
	#macro c_sunset_start				hex_to_color("B2353B")
	#macro c_sunset_end					hex_to_color("C04E37")
	#macro c_normal						make_color_rgb(127, 127, 255)
	
	// Audio
	#macro sample_rate					44100
	#macro sample_size					4
	#macro sample_max					32767
	#macro sample_avg_per_sec			100
	
	// Interface
	#macro glow_alpha					0.5
	#macro shadow_size					5
	#macro shadow_alpha					0.1
	#macro view_3d_control_size			0.2125
	#macro view_3d_control_width		20
	#macro view_3d_box_size				12
	#macro button_padding				24
	#macro button_icon_padding			52
	#macro snap_min						0.000001
	#macro dragger_width				74
	#macro label_height					9
	
	// Values
	#macro null							noone
	#macro no_limit						100000000
	#macro default_model				"human"
	#macro default_model_part			"head"
	#macro default_special_block		"chest"
	#macro default_block				"grass_block"
	#macro default_item					"item/diamond_sword"
	#macro default_ground				"block/grass_block_top"
	#macro particle_sheet				-5
	#macro particle_template			-6
	#macro normal_buffer_scale			8
	
	// World
	#macro block_size					16
	#macro item_size					16
	#macro clip_near					1
	
	// Vectors and matrices
	#macro X							0
	#macro Y							1
	#macro Z							2
	#macro W							3
	#macro MAT_X						12
	#macro MAT_Y						13
	#macro MAT_Z						14
	#macro PATH_SCALE					4
	#macro PATH_TANGENT_X				5
	#macro PATH_TANGENT_Y				6
	#macro PATH_TANGENT_Z				7
	#macro PATH_NORMAL_X				8
	#macro PATH_NORMAL_Y				9
	#macro PATH_NORMAL_Z				10
	
	#macro MAT_IDENTITY					matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)
}
