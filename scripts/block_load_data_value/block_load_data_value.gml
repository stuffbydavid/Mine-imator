/// block_load_data_map(value, map, bitmask, bitbase)
/// @arg value
/// @arg map
/// @arg bitmask

var value, map, bitmask, bitbase;
value = string_get_real(argument0)
map = argument1
bitmask = argument2
bitbase = argument3

var dataname, datatype, datadefaultname, datastates, databrightness, datavars;
dataname = ""
datatype = ""
datadefaultname = ""
datastates = ""
databrightness = null
datavars = null

if (is_string(map[?"name"]))
	dataname = map[?"name"]

if (is_string(map[?"type"]))
	datatype = map[?"type"]
		
if (is_string(map[?"default_name"]))
	datadefaultname = map[?"default_name"]
	
if (is_string(map[?"states"]))
	datastates = map[?"states"] // Store filename
	
if (is_real(map[?"brightness"]))
	databrightness = map[?"brightness"]
	
if (is_string(map[?"set"]))
{
	datavars = ds_map_create()
	block_load_vars(datavars, map[?"set"])
}
	
// Insert into array
if (bitmask > 0)
{
	for (var d = 0; d < 16; d++)
	{
		// Check data value with bit mask, skip if not matched
		if ((d & bitmask) / bitbase != value)
			continue
		
		if (dataname != "")
			data_name[d] = dataname
			
		if (datatype != "")
			data_type[d] = datatype
			
		if (datadefaultname != "")
			data_default_name[d] = datadefaultname
			
		if (datastates != "")
			data_states[d] = datastates
			
		if (databrightness != null)
			data_brightness[d] = databrightness
			
		if (datavars != null)
		{
			if (data_vars[d] = vars)
			{
				data_vars[d] = ds_map_create()
				if (vars != null)
					ds_map_copy(data_vars[d], vars)
			}
			ds_map_merge(data_vars[d], datavars)
		}
	}
}
else
{
	if (dataname != "")
		data_name[value] = dataname
		
	if (datatype != "")
		data_type[value] = datatype
		
	if (datadefaultname != "")
		data_default_name[value] = datadefaultname
		
	if (datastates != "")
		data_states[value] = datastates
		
	if (databrightness != null)
		data_brightness[d] = databrightness
			
	if (datavars != null)
	{
		if (data_vars[value] = vars)
		{
			data_vars[value] = ds_map_create()
			if (vars != null)
				ds_map_copy(data_vars[value], vars)
		}
		ds_map_merge(data_vars[value], datavars)
	}
}

if (datavars != null)
	ds_map_destroy(datavars)