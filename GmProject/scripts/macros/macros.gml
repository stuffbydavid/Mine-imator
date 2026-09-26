/// macros()
/// @desc Defines constants used in the project.

function macros()
{
	// Debug
	#macro dev_mode						true
	#macro dev_mode_debug_names			dev_mode && false

	// Versions
	#macro mineimator_version			"2.1.0"		// Base Mine-imator version
	#macro mineimator_version_sub		""			// Mod name and version (e.g. "Community Build 1.0.0")
	#macro mineimator_version_extra		"WIP"		// Additional suffix (e.g. "Alpha 1" or "Pre-Release 2")
	#macro mineimator_version_full		(mineimator_version + ((mineimator_version_sub != "") ? " " + mineimator_version_sub : "") + ((mineimator_version_extra != "") ? " (" + mineimator_version_extra + ")" : ""))
	#macro mineimator_version_date		"2026.09.XX"
	#macro minecraft_assets_version		"26.3"
	
	// File formats
	#macro project_format				e_project.FORMAT_210
	#macro settings_format				e_settings.FORMAT_200
	#macro render_settings_format		e_render_settings.FORMAT_210
	#macro minecraft_assets_format		e_minecraft_assets.FORMAT_201
	
	// Directories
	#macro data_directory				working_directory + "Data/"
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
	#macro temp_file					file_directory_get() + "tmp.file"
	#macro temp_image					file_directory_get() + "tmp.png"
	#macro download_image_file			file_directory_get() + "download.png"
	#macro unzip_directory				file_directory_get() + "unzip/"
	#macro render_default				"performance"
	#macro render_default_file			render_directory + render_default + ".mirender"
	#macro render_presets				array("performance.mirender", "balanced.mirender", "extreme.mirender")
	#macro render_preset_default		"balanced.mirender"
	#macro render_preset_default_name	"balanced"
	#macro asset_exts					"*.miobject;*.miframes;*.zip;*.schematic;*.schem;*.miproject;*.miparticles;*.mimodel;*.png;*.jpg;*.json;*.ttf;*.mp3;*.wav;*.ogg;*.flac;*.wma;*.m4a;*.object;*.keyframes;*.particles;*.mproj;*.mani;*.blocks;*.nbt;*.dat;"
	
	// Minecraft structure
	#macro mc_file_directory			file_directory_get() + "Minecraft_unzip/"
	#macro mc_assets_directory			"assets/minecraft/"
	#macro mc_models_directory			mc_assets_directory + "models/"
	#macro mc_blockstates_directory		mc_assets_directory + "blockstates/"
	#macro mc_textures_directory		mc_assets_directory + "textures/"
	#macro mc_character_directory		mc_models_directory + "character/"
	#macro mc_equipment_directory		mc_models_directory + "equipment/"
	#macro mc_special_block_directory	mc_models_directory + "special_block/"
	#macro mc_block_directory			mc_models_directory + "block/"
	#macro mc_loops_directory			mc_character_directory + "loops/"
	
	#macro mc_pack_image_file			"pack.png"
	#macro mc_grass_image_file			mc_textures_directory + "colormap/grass.png"
	#macro mc_foliage_image_file		mc_textures_directory + "colormap/foliage.png"
	#macro mc_dry_foliage_image_file	mc_textures_directory + "colormap/dry_foliage.png"
	#macro mc_particles_image_file		mc_textures_directory + "particle/particles.png"
	#macro mc_explosion_image_file		mc_textures_directory + "entity/explosion.png"
	#macro mc_sun_image_file			mc_textures_directory + "environment/celestial/sun.png"
	#macro mc_moon_phases_directory		mc_textures_directory + "environment/celestial/moon/"
	#macro mc_moon_phase_0_image_file	mc_moon_phases_directory + "full_moon.png"
	#macro mc_moon_phase_1_image_file	mc_moon_phases_directory + "waning_gibbous.png"
	#macro mc_moon_phase_2_image_file	mc_moon_phases_directory + "third_quarter.png"
	#macro mc_moon_phase_3_image_file	mc_moon_phases_directory + "waning_crescent.png"
	#macro mc_moon_phase_4_image_file	mc_moon_phases_directory + "new_moon.png"
	#macro mc_moon_phase_5_image_file	mc_moon_phases_directory + "waxing_crescent.png"
	#macro mc_moon_phase_6_image_file	mc_moon_phases_directory + "first_quarter.png"
	#macro mc_moon_phase_7_image_file	mc_moon_phases_directory + "waxing_gibbous.png"
	#macro mc_clouds_image_file			mc_textures_directory + "environment/clouds.png"
	#macro mc_glint_armor_file			mc_textures_directory + "misc/enchanted_glint_armor.png"
	#macro mc_glint_item_file			mc_textures_directory + "misc/enchanted_glint_item.png"
	#macro mc_unknown_asset_warning		" is not defined in the translation, the key will be formatted"
	
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
	#macro link_modelbench				"https://www.mineimator.com/modelbench"
	#macro link_twitter					"https://www.mineimator.com/tweets"
	#macro link_discord					"https://www.mineimator.com/discord"
	#macro link_donate					"https://www.mineimator.com/donate"
	#macro show_modelbench_popup		!debug_mode && true
	#macro http_ok						200
	#macro http_bad_request				400
	
	// Colors
	#macro c_controls					make_color_rgb(40, 40, 40)
	#macro c_sky_overworld				make_color_rgb(129, 172, 255)
	#macro c_sky_the_nether				make_color_rgb(48, 7, 8)
	#macro c_sky_the_end				make_color_rgb(23, 18, 23)
	#macro c_fog_bright					make_color_rgb(246, 253, 255)
	#macro c_clouds						make_color_rgb(255, 255, 255)
	#macro c_sunlight					make_color_rgb(255, 247, 228)
	#macro c_ambient					make_color_rgb(102, 112, 140)
	#macro c_night_sky					make_color_rgb(2, 2, 3)
	#macro c_fog_night					make_color_rgb(10, 11, 20)
	#macro c_night_clouds				make_color_rgb(25, 25, 38)
	#macro c_stars						make_color_rgb(63, 63, 63)
	#macro c_night						make_color_rgb(14, 14, 24)
	#macro c_clouds_top					make_color_rgb(255, 255, 255)
	#macro c_clouds_sideslight			make_color_rgb(229, 229, 229) //(215, 222, 234)
	#macro c_clouds_sidesdark			make_color_rgb(204, 204, 204) //(194, 201, 215)
	#macro c_clouds_bottom				make_color_rgb(178, 178, 178) //(174, 181, 193)
	#macro c_plains_biome_grass			make_color_rgb(145, 189, 89)
	#macro c_plains_biome_foliage		make_color_rgb(119, 171, 47)
	#macro c_plains_biome_foliage_2		make_color_rgb(98, 168, 87)
	#macro c_plains_biome_dry_foliage	make_color_rgb(163, 117, 70)
	#macro c_plains_biome_water			make_color_rgb(63, 118, 228)
	#macro c_sunset_start				hex_to_color("B2353B")
	#macro c_sunset_end					hex_to_color("C04E37")
	#macro c_normal						make_color_rgb(127, 127, 255)
	#macro c_text_outline				make_color_rgb(92, 80, 255)
	
	// Encoding
	#macro sample_rate					44100
	#macro sample_size					4
	#macro sample_max					32767
	#macro sample_avg_per_sec			100
	#macro movie_bit_rate			    2500000
	
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
	#macro transform_snap				0.0001
	#macro dragger_width				74
	#macro label_height					9
	#macro load_assets_width			780
	#macro load_assets_height			450
	#macro panel_width					360
	#macro panel_bottom_height			300
	#macro panel_top_height				205
	#macro bench_min_width				530
	#macro bench_max_width				800
	#macro bench_initial_width			604
	#macro bench_initial_height			345
	#macro bench_list_percent			0.8
	#macro bench_soundlist_percent		1
	#macro list_minimum_items			7
	#macro soundlist_minimum_items		9
	#macro list_center_max				500
	
	// Values
	#macro null							noone
	#macro project_pack_res				-3
	#macro particle_sheet				-5
	#macro particle_template			-6
	#macro no_limit						100000000
	#macro normal_buffer_scale			8
	#macro default_model				"human"
	#macro default_model_part			"head"
	#macro default_model_part_model		"armor"
	#macro default_equipment			"armor"
	#macro default_special_block		"chest"
	#macro default_block				"grass_block"
	#macro default_item					"item/diamond_sword"
	#macro overworld_ground				"block/grass_block_top"
	#macro overworld_biome				"plains"
	#macro the_nether_biome				"nether_wastes"
	#macro the_nether_ground			"block/netherrack"
	#macro the_end_biome				"the_end"
	#macro the_end_ground				"block/end_stone"
	#macro fog_far						10000
	#macro fog_near						2000
	#macro fog_size						2000
	#macro fog_height					1250
	#macro armor_parts					array("helmet", "chestplate", "leggings", "boots")
	#macro schematic_folders			array("Buildings", "Biomes", "Trees", "Structures", "Other")
	#macro schematic_default			array("House 1", "Forest", "Oak tree 1", "Dungeon", "Creek")
	#macro scenery_large_threshold		300
	#macro scenery_instant_threshold	20 * 1024 // 20kb
	#macro scenery_timeline_prompt		20
	#macro scenery_timeline_limit		512
	#macro sound_filters				array("ambient", "block", "damage", "dig", "enchant", "entity", "event", "fire", "fireworks", "item", "liquid", "minecart", "mob", "note", "portal", "random", "step", "tile", "ui", "other")
	#macro sound_default				"Step / Grass 1"
	#macro music_filters				array("game", "menu", "records", "other")
	#macro music_default				"Records / Cat"
	#macro particle_folders				array("Effects", "Weather")
	#macro particle_default				array("Default", "Snow")
	#macro default_text					"AaBbCc"
	
	// Parenting actions for right/left arm
	#macro item_parent_action			array(null, true, vec3(0, 0.7, -5), vec3(-90, -90, -90), vec3(0.5))
	#macro bow_parent_action_right		array(null, true, vec3(0.8, -6, 0.7), vec3(-183, -54, -85), vec3(0.9))
	#macro bow_parent_action_left		array(null, true, vec3(-0.8, -6, 0.7), vec3(-177, -54, -95), vec3(0.9))
	#macro tool_parent_action			array(null, true, vec3(0, 2, 0), vec3(0, 145, 90), vec3(0.85))
	#macro rod_parent_action			array(null, true, vec3(0, 2, -9), vec3(180, 145, 90), vec3(0.85))
	#macro crossbow_parent_action_right	array(null, true, vec3(4.25, 2, -5.5), vec3(-2, 120, 0), vec3(0.9))
	#macro crossbow_parent_action_left	array(null, true, vec3(5.6, 2, -2.85), vec3(-2, 150, 0), vec3(0.9))
	#macro spear_parent_action			array(null, true, vec3(0, -3, -11.5), vec3(0, 41, 90), vec3(1.25))
	#macro block_parent_action_right	array(null, true, vec3(0, 3.5, -9.5), vec3(-15, 15, 135), vec3(0.4))
	#macro block_parent_action_left		array(null, true, vec3(0, 3.5, -9.5), vec3(15, 15, 45), vec3(0.4))
	
	// World
	#macro block_size					16
	#macro block_half_size				8
	#macro block_size_list				array(16, 32, 64)
	#macro item_size					16
	#macro clip_far						30000
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
