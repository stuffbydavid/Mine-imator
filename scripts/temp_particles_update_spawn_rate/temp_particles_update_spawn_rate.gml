/// temp_particles_update_spawn_rate(ptype, value)
/// @arg ptype
/// @arg value
/// @desc Updates after adding a % of spawn rate to the given particle type in the template.

function temp_particles_update_spawn_rate(ptype, val)
{
	var sub = val;
	
	// Change other types, the spawn rates must add up to 100%
	for (var t = 0; t < ds_list_size(pc_type_list); t++)
	{
		var curptype = pc_type_list[|t];
		if (curptype = ptype)
			continue
		curptype.spawn_rate -= val / (ds_list_size(pc_type_list) - 1)
		sub -= val / (ds_list_size(pc_type_list) - 1)
		if (curptype.spawn_rate < 0)
			sub += abs(curptype.spawn_rate)
		curptype.spawn_rate = max(0, curptype.spawn_rate)
	}
	
	// Subtract remaining percent
	if (sub > 0)
	{
		for (var t = 0; t < ds_list_size(pc_type_list); t++)
		{
			var curptype = pc_type_list[|t];
			if (curptype = ptype || curptype.spawn_rate = 0)
				continue
			
			curptype.spawn_rate -= sub
			if (curptype.spawn_rate < 0)
				sub += abs(curptype.spawn_rate)
			else // Nothing left to subtract
				break
			
			curptype.spawn_rate = max(0, curptype.spawn_rate)
		}
	}
}
