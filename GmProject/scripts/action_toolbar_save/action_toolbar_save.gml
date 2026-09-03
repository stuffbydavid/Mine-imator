/// action_toolbar_save()

function action_toolbar_save()
{
	if (directory_exists_lib(project_folder))
	{
		project_save()
		toast_new(e_toast.POSITIVE, text_get("alertprojectsaved"))
	}
	else
		error("errorsaveproject")
}
