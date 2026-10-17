function trial_startup()
{
	globalvar trial_version, key_current, key_current_date, key_current_date_invalid, key_expired, key_expired_dismissed;
	trial_version = (debug_full ? false : true)
	
	key_current = ""
	key_current_date = 0
	key_current_date_invalid = false
	key_expired = false
	key_expired_dismissed = false
	
	if (!file_exists_lib(key_file))
		return 0

	var map = json_load(key_file);
	if (!ds_map_valid(map))
		return 0

	if (ds_map_exists(map, "format")    && is_real(map[?"format"]) && map[?"format"] = e_key_format.FORMAT_210 &&
		ds_map_exists(map, "key")       && is_string(map[?"key"]) &&
		ds_map_exists(map, "date")      && is_real(map[?"date"]) &&
		ds_map_exists(map, "dismissed") && is_bool(map[?"dismissed"]))
	{
		key_current = map[?"key"]
		key_current_date = map[?"date"]
		
		if (date_month_span(key_current_date, date_current_datetime()) > 6)
		{
			key_expired = true
			key_expired_dismissed = map[?"dismissed"]
		}
		else if (key_current_date > date_current_datetime())
			key_current_date_invalid = true
		
		else if (key_valid(key_current))
			trial_version = false
	}
	
	ds_map_destroy(map)
}
