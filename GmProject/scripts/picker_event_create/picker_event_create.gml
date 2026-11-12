function picker_event_create()
{
	// Picker inherits from sortlist
	sortlist_event_create()
	
	grid_view = true
	asset_picker_model = false
	search_slots = null

	tip_slot = -1
	tip_time = 0
	last_state = null
}
