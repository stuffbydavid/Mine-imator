/// temp_particles_update_spawn_rate(ptype, value)
/// @arg ptype
/// @arg value
/// @desc Updates after adding a % of spawn rate to the given particle type in the template.

var ptype, val, sub;
ptype = argument0
val = argument1
sub = val

// Change other types, the spawn rates must add up to 100%
for (var t = 0; t < pc_types; t++)
{
    if (pc_type[t] = ptype)
        continue
    pc_type[t].spawn_rate -= val / (pc_types - 1)
    sub -= val / (pc_types - 1)
    if (pc_type[t].spawn_rate < 0)
        sub += abs(pc_type[t].spawn_rate)
    pc_type[t].spawn_rate = max(0, pc_type[t].spawn_rate)
}

// Subtract remaining percent
if (sub > 0)
{
    for (var t = 0; t < pc_types; t++)
	{
        if (pc_type[t] = ptype || pc_type[t].spawn_rate = 0)
            continue
        
        pc_type[t].spawn_rate -= sub
        if (pc_type[t].spawn_rate < 0)
            sub += abs(pc_type[t].spawn_rate)
        else // Nothing left to subtract
            break
        
        pc_type[t].spawn_rate = max(0, pc_type[t].spawn_rate)
    }
}
