/// @desc Read supported schematic entities into scenery parts.

function builder_read_entities(entities, offset = null)
{
	if (!ds_list_valid(entities))
		return 0

	for (var i = 0; i < ds_list_size(entities); i++)
	{
		var entity, data, entityid, model, pos, entityx, entityy, entityz, scr, part;
		entity = entities[|i]
		if (!ds_map_valid(entity))
			continue

		// Data compound
		data = entity[?"Data"]
		if (!ds_map_valid(data))
			data = entity[?"nbt"]
		if (!ds_map_valid(data))
			data = entity[?"TileNBT"]
		if (!ds_map_valid(data))
			data = entity

		// ID
		entityid = data[?"id"]
		if (!is_string(entityid))
			entityid = entity[?"Id"]
		if (!is_string(entityid))
			continue

		entityid = string_lower(string_replace(entityid, "minecraft:", ""))
		
		// Get model
		model = mc_assets.entity_model_map[?entityid]
		if (is_undefined(model))
			continue
			
		// Position
		pos = entity[?"Pos"]
		if (!ds_list_valid(pos))
			pos = entity[?"pos"]
		if (!ds_list_valid(pos))
			pos = data[?"Pos"]
		
		if (!ds_list_valid(pos) || ds_list_size(pos) != 3)
			continue

		entityx = pos[|X]
		entityy = pos[|Y]
		entityz = pos[|Z]
		
		if (offset != null)
		{
			entityx += offset[X]
			entityy += offset[Y]
			entityz += offset[Z]
		}

		if (!is_real(entityx) || !is_real(entityy) || !is_real(entityz) ||
			entityx < 0 || entityy < 0 || entityz < 0 ||
			entityx >= build_size[X] || entityy >= build_size[Z] || entityz >= build_size[Y])
			continue

		scr = asset_get_index("block_entity_" + entityid)
		if (scr < 0)
			continue

		part = script_execute(scr, data, vec3(entityx, entityy, entityz), model)
		if (is_array(part))
		{
			// Append timeline type
			part[scenery_entity_tl_type_index] = model.entity_tl_type
			array_add(sch_entities, part, false)
		}
	}
}
