/// @desc Resolves legacy fire support and flammable neighbors.

function block_fire_can_burn(block, stateid)
{
	if (block = null)
		return false

	switch (block.name)
	{
		case "log":
		case "wood":
		case "planks":
		case "slab":
		case "stairs":
		case "fence":
		case "fence_gate":
			return array_contains([ "oak", "spruce", "birch", "jungle", "acacia", "dark_oak" ],
				block_get_state_id_value(block, stateid, "variant"))

		case "leaves":
		case "wool":
		case "carpet":
		case "tnt":
		case "bookshelf":
		case "vine":
		case "coal_block":
		case "hay_block":
		case "grass":
		case "flower":
		case "double_plant":
			return true
	}

	return false
}

function block_set_fire()
{
	if (!builder_scenery_legacy)
		return 0

	var connect, variant;
	connect = array_create(5, "false")
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")

	var supported = false;
	if (!build_edge[ZN])
	{
		var belowpos, below, belowstate;
		belowpos = vec3_add(build_pos, dir_get_vec3(ZN))
		below = builder_get_block(belowpos[X], belowpos[Y], belowpos[Z])
		belowstate = builder_get_state_id(belowpos[X], belowpos[Y], belowpos[Z])
		supported = block_fire_can_burn(below, belowstate)

		// Read source models so support does not depend on generation order
		if (below != null && !supported)
		{
			var models = below.state_id_model_obj[belowstate];
			if (!is_array(models))
				models = [ models ]

			for (var m = 0; m < array_length(models); m++)
			{
				if (models[m] = null || is_undefined(models[m]) || models[m].model_amount = 0)
					continue

				var model = models[m].model[0];
				if (model.face_full[ZP] && model.face_min_depth[ZP] = e_block_depth.DEPTH0)
					supported = true
			}
		}
	}

	for (var d = XP; d <= ZP && !supported; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])

		if (block_fire_can_burn(block, builder_get_state_id(pos[X], pos[Y], pos[Z])))
			connect[d] = "true"
	}

	block_state_id_current = block_get_state_id(block_current, [
		"variant", variant, "east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN], "up", connect[ZP]
	])

	return 0
}
