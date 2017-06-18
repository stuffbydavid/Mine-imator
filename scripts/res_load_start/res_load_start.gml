/// res_load_start()
/// @desc Starts loading the resource.

switch (type)
{
	case "schematic":
	{
		load_stage = "open"
		with (app)
		{
			popup_loading.text = text_get("sceneryloadopen")
			popup_loading.caption = ""
			popup_loading.load_script = res_load_scenery
		}
		break
	}
	
	case "audio":
	{
		load_stage = "open"
		with (app)
		{
			popup_loading.text = text_get("audioloadopen")
			popup_loading.caption = text_get("audioloadcaption", other.filename)
			popup_loading.load_script = res_load_audio
		}
		break
	}
	
	case "pack":
	{
		load_stage = "unzip"
		with (app)
		{
			popup_loading.text = text_get("packloadunzip")
			popup_loading.caption = text_get("packloadcaption", other.filename)
			popup_loading.load_script = res_load_pack
		}
		break
	}
}