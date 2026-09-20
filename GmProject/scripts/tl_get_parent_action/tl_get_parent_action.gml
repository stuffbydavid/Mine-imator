/// tl_get_parent_action()
/// Returns an optional array containing target, bend, transform and lock info when a timeline is parented.

function tl_get_parent_action(newparent)
{
	var targetmap = null;
	
	if (newparent = app || newparent = app.timeline_move_obj)
		return null

	// Block categories are place targets to block and scenery objects
	if (type_is_block(type))
	{
		if ((newparent.type = e_tl_type.BLOCK || newparent.type = e_tl_type.SCENERY) &&
			!(type = e_tl_type.SCENERY && newparent.type = e_tl_type.SCENERY)) // Don't parent scenery to each other
			return array(newparent)
	}

	// Model placement targets
	if ((type = e_tl_type.CHARACTER || type = e_tl_type.EQUIPMENT || type = e_tl_type.SPECIAL_BLOCK || type = e_tl_type.MODEL) && temp != null)
	{
		var model = mc_assets.model_name_map[?temp.model_name];
		if (!is_undefined(model))
			targetmap = model.place_target_map
	}

	// Item placement targets
	if (type = e_tl_type.ITEM && !item_custom_slot && item_slot >= 0)
	{
		var decodedslot = minecraft_assets_texture_picker_slot_decode(item_slot, mc_assets.item_texture_list)
		if (decodedslot[0] >= 0)
		{
			var itemname = mc_assets.item_texture_list[decodedslot[0]][|decodedslot[1]]
			targetmap = minecraft_item_place_target_map[?itemname]
		}
	}

	// Apply an exact body part target
	if (newparent.type = e_tl_type.MODEL_PART && newparent.model_part != null && ds_map_valid(targetmap))
	{
		var action = targetmap[?newparent.model_part_name]
		if (is_array(action))
		{
			action = array_copy_1d(action)
			action[e_parent_action.TARGET] = newparent
			return action
		}
	}

	// Equipment uses the target model root
	if (type = e_tl_type.EQUIPMENT && temp != null)
	{
		var root = newparent;
		if (root.type = e_tl_type.MODEL_PART)
			root = root.part_of
		
		if (root != null && root.type = e_tl_type.MODEL)
			return array(root, true, vec3(0), vec3(0), vec3(1), true)
		
		if (root != null && (root.type = e_tl_type.CHARACTER || root.type = e_tl_type.SPECIAL_BLOCK) && root.temp != null)
		{
			var parentmodel = mc_assets.model_name_map[?root.temp.model_name];
			if (!is_undefined(parentmodel) && parentmodel.equipment_list != null &&
				ds_list_find_index(parentmodel.equipment_list, temp.model_name) >= 0)
				return array(root, true, vec3(0), vec3(0), vec3(1), true)
		}
	}
	
	// Equipment model parts attach to matching model parts
	if (type = e_tl_type.MODEL_PART && model_part_name != "" &&
		newparent.type = e_tl_type.MODEL_PART && newparent.model_part != null &&
		newparent.model_part_name = model_part_name)
		return array(newparent, true, vec3(0), vec3(0), vec3(1), true)

	// Unmapped objects attach to lower arm halves of characters/models
	if (newparent.type = e_tl_type.MODEL_PART && newparent.part_of != null && newparent.model_part != null &&
		(newparent.part_of.type = e_tl_type.CHARACTER || newparent.part_of.type = e_tl_type.MODEL) &&
		(newparent.model_part_name = "left_arm" || newparent.model_part_name = "right_arm"))
	{
		if (type = e_tl_type.ITEM)
		{
			var action = array_copy_1d(item_parent_action);
			action[e_parent_action.TARGET] = newparent
			return action
		}
		
		if (!type_is_block(type))
			return null
		
		// Block
		var action, targetscale, targetsize;
		if (newparent.model_part_name = "right_arm")
			action = array_copy_1d(block_parent_action_right)
		else
			action = array_copy_1d(block_parent_action_left)
		targetscale = action[e_parent_action.SCA][X]
		targetsize = vec3(1)
		
		// Scale down by number of blocks in longest direction
		if (type = e_tl_type.SCENERY && temp != null && temp.scenery != null)
		{
			var targetrepeat = vec3(1);
			if (temp.block_repeat_enable)
				targetrepeat = temp.block_repeat
			targetsize = vec3_mul(temp.scenery.scenery_size, targetrepeat)
		}
		else if (type = e_tl_type.BLOCK && temp != null)
		{
			if (temp.block_repeat_enable)
				targetsize = temp.block_repeat
		}

		targetscale /= max(1, targetsize[X], targetsize[Y])
		action[e_parent_action.TARGET] = newparent
		action[e_parent_action.SCA] = vec3(targetscale)
		return action
	}

	return null
}
