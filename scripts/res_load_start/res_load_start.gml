/// res_load_start()
/// @desc Starts loading the resource.

switch (type)
{
	case "schematic":
	case "fromworld":
	{
		load_stage = "open"
		with (app)
		{
			popup_loading.text = text_get("loadsceneryopen")
			popup_loading.load_script = res_load_scenery
		}
		break
	}
	
	case "sound":
	{
		load_stage = "open"
		with (app)
		{
			popup_loading.text = text_get("loadaudioread")
			popup_loading.caption = text_get("loadaudiocaption", other.filename)
			popup_loading.load_script = res_load_audio
		}
		break
	}
	
	case "pack":
	case "packunzipped":
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