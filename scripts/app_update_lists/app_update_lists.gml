/// app_update_lists()
/// @desc Execute scripts in clicked item lists

function app_update_lists()
{
	if (list_item_script != null)
	{
		script_execute(list_item_script, list_item_script_value)
		
		list_item_script = null
		list_item_script_value = null
		list_item_value = null
	}
}
