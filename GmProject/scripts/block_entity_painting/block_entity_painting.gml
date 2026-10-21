/// @desc Position a painting model from its entity data.

function block_entity_painting(data, pos, model)
{
	// Variant
	var variant, variants, file;
	variant = data[?"variant"]
	if (!is_string(variant))
		variant = data[?"Motive"]
	if (!is_string(variant))
		return null

	variant = string_lower(string_replace(variant, "minecraft:", ""))
	variant = string_replace(variant, "painting/", "")
	
	switch (variant)
	{
		case "skullandroses":	variant = "skull_and_roses"; break
		case "burningskull":	variant = "burning_skull"; break
		case "donkeykong":		variant = "donkey_kong"; break
	}

	variants = model.states_map[?"variant"]
	file = null
	
	for (var v = 0; v < variants.value_amount; v++)
	{
		if (variants.value_name[v] = "painting_" + variant)
		{
			file = variants.value_file[v]
			break
		}
	}

	if (file = null)
		return null

	// Facing
	var facing, legacydir, rotationfacing;
	facing = data[?"facing"]
	legacydir = false
	if (!is_real(facing))
	{
		facing = data[?"Dir"]
		legacydir = is_real(facing)
	}
	if (!is_real(facing))
		facing = data[?"Facing"]
	if (!is_real(facing))
		facing = data[?"Direction"]
	if (!is_real(facing))
		return null

	facing = ((facing mod 4) + 4) mod 4
	
	// Position
	var entityx, entityy, entityz;
	entityx = pos[X]
	entityy = pos[Y] - (file.bounds_parts_end[Z] - file.bounds_parts_start[Z]) / (2 * block_size)
	entityz = pos[Z]

	// Apply offset
	if (legacydir)
	{
		var off = 1 / block_size;
		switch (facing)
		{
			case 0: entityz += off; break
			case 1: entityx += off; break
			case 2: entityz -= off; break
			case 3: entityx -= off; break
		}
	}
	else
	{
		var off = 1 / 32;
		switch (facing)
		{
			case 0: entityz -= off; break
			case 1: entityx += off; break
			case 2: entityz += off; break
			case 3: entityx -= off; break
		}
	}

	// Flip legacy paintings
	rotationfacing = facing
	if (legacydir && (facing = 0 || facing = 2))
		rotationfacing = (facing + 2) mod 4

	return [
		model.name,
		[ "variant", "painting_" + variant ],
		vec3(entityx, entityz, entityy),
		vec3(0, 0, -rotationfacing * 90),
		point3D(0)
	]
}
