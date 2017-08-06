/// res_load_start()
/// @desc Starts loading the resource.

switch (type)
{
	case "schematic":
	{
		load_stage = "open"
		with (app)
		{
			popup_loading.text = text_get("loadsceneryopen")
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
			popup_loading.text = text_get("loadaudioopen")
			popup_loading.caption = text_get("loadaudiocaption", other.filename)
			popup_loading.load_script = res_load_audio
		}
		break
	}
	
	case "pack":
	{
		load_stage = "unzip"
		with (app)
		{
			popup_loading.text = text_get("loadpackunzip")
			popup_loading.caption = text_get("loadpackcaption", other.filename)
			popup_loading.load_script = res_load_pack
		}
		break
	}
}