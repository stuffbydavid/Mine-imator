/// action_recent_pin(item)
/// @arg item

function action_recent_pin(item)
{
	item.pinned = !item.pinned
	recent_list_update = true
}
