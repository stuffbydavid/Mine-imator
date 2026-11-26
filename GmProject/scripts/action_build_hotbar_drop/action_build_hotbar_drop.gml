/// @desc Moves, copies, swaps or inserts a dragged block in the hotbar.

function action_build_hotbar_drop()
{
	var hobj, list, edits, hotbar, block, insertion, blocks;
	list = build_hotbars.list

	if (history_undo || history_redo)
		hobj = history_data
	else
	{
		var source, target;
		source = ds_list_find_index(list.list, build_drag_source)
		target = ds_list_find_index(list.list, build_drag_target)

		// Returning a block to its source leaves the hotbar unchanged
		if (!build_drag_insert && source >= 0 && source = target && build_drag_source_slot = build_drag_target_slot)
		{
			build_drag_source.blocks[build_drag_source_slot] = [
				build_drag_block[0], build_drag_block[1], array_copy_1d(build_drag_block[2])
			]
			action_build_hotbar_select(build_drag_target_slot)
			return 0
		}

		block = [ false, "", [] ]
		if (target >= 0 && !build_drag_insert)
			block = build_drag_target.blocks[build_drag_target_slot]

		edits = []
		if (source >= 0 && (!build_drag_copy || block[1] != ""))
			array_add(edits, [ source, build_drag_source_slot, build_drag_block, block ], false)

		if (target >= 0 && !build_drag_insert)
			array_add(edits, [ target, build_drag_target_slot, block, build_drag_block ], false)

		if (array_length(edits) = 0 && !(target >= 0 && build_drag_insert))
			return 0

		hobj = history_set(action_build_hotbar_drop)
		hobj.hotbar_edits = edits
		hobj.hotbar_insert = null
		if (target >= 0 && build_drag_insert)
			hobj.hotbar_insert = [ target, build_drag_target_slot, build_drag_block ]

		hobj.hotbar_selected = build_hotbars.selected
		hobj.hotbar_slot = build_hotbar_slot
		hobj.hotbar_new_slot = build_hotbar_slot
		if (target >= 0)
			hobj.hotbar_new_slot = build_drag_target_slot
	}

	// Remove inserted cells before restoring the original slot positions
	insertion = hobj.hotbar_insert
	if (history_undo && insertion != null)
	{
		hotbar = list.list[|insertion[0]]
		blocks = []
		array_copy(blocks, 0, hotbar.blocks, 0, insertion[1])
		array_copy(blocks, insertion[1], hotbar.blocks, insertion[1] + 1, array_length(hotbar.blocks) - insertion[1] - 1)
		hotbar.blocks = blocks
	}

	// Copy states so later edits cannot change the undo or redo data
	edits = hobj.hotbar_edits
	for (var i = 0; i < array_length(edits); i++)
	{
		var edit = edits[i];
		hotbar = list.list[|edit[0]]
		if (history_undo)
			block = edit[2]
		else
			block = edit[3]

		hotbar.blocks[edit[1]] = [ block[0], block[1], array_copy_1d(block[2]) ]
	}

	// Insert after source edits so their indices stay unchanged
	if (!history_undo && insertion != null)
	{
		hotbar = list.list[|insertion[0]]
		block = insertion[2]
		blocks = []
		array_copy(blocks, 0, hotbar.blocks, 0, insertion[1])
		array_add(blocks, [ block[0], block[1], array_copy_1d(block[2]) ], false)
		array_copy(blocks, insertion[1] + 1, hotbar.blocks, insertion[1], array_length(hotbar.blocks) - insertion[1])
		hotbar.blocks = blocks
	}

	if (history_undo)
		build_hotbar_slot = hobj.hotbar_slot
	else
		build_hotbar_slot = hobj.hotbar_new_slot

	sortlist_update(list)
	
	action_build_hotbars_list(list.list[|hobj.hotbar_selected])
}
