/// action_setting_texture_filtering_level(value, add)
/// @arg value
/// @arg add

setting_texture_filtering_level = setting_texture_filtering_level * argument1 + argument0
texture_set_mipmap_level(setting_texture_filtering_level)