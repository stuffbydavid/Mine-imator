/// list_item_event_destroy()

if (actions_left != null)
	ds_list_destroy(actions_left)

if (actions_right != null)
	ds_list_destroy(actions_right)

// Delete micro animation
if (ds_map_exists(microanis, string(id)))
{
	instance_destroy(microanis[?string(id)])
	ds_map_delete(microanis, string(id))
}
