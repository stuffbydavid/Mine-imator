/// app_event_http()

if (async_load[?"id"] = popup_downloadskin.http) // Download skin
{
    popup_downloadskin.http = null
    popup_downloadskin.fail_message = text_get("errordownloadskinuser", string_remove_newline(popup_downloadskin.username))
	
    if (popup_downloadskin.texture)
	{
        texture_free(popup_downloadskin.texture)
        popup_downloadskin.texture = null
    }
	
    if (async_load[?"http_status"] = 200)
	{
        if (file_exists_lib(download_file))
		{
            popup_downloadskin.texture = texture_create(download_file)
            if (!popup_downloadskin.texture)
                popup_downloadskin.fail_message = text_get("errordownloadskininternet")
            else
                popup_downloadskin.fail_message = ""
        }
    }
}

if (async_load[?"id"] = alert_news_http) // Check news
{
    alert_news_http = null
    if (async_load[?"http_status"] = 200)
	{
        var decoded = json_decode(async_load[?"result"]);
		if (decoded >= 0)
		{
			newslist = decoded[?"default"]
            for (var n = 0; n < ds_list_size(newslist); n++)
			{
                var newsmap, title, text, icon, button, buttonurl, iid;
                newsmap = newslist[|n]
				
                if (!is_undefined(newsmap) && ds_exists(newsmap, ds_type_map))
				{
                    title = newsmap[?"title"]
                    text = newsmap[?"text"]
                    icon = newsmap[?"icon"]
                    switch (icon)
					{
                        case "website":		icon = icons.websitesmall;		break
                        case "forums":		icon = icons.forumssmall;		break
                        case "save":		icon = icons.savesmall;			break
                        case "download":	icon = icons.downloadsmall;		break
                        case "cake":		icon = icons.cakesmall;			break
                        case "upgrade":		icon = icons.upgradesmall;		break
                        case "render":		icon = icons.rendersmall;		break
                        default:			icon = null	;					break
                    }
					
                    button = newsmap[?"button"]
                    buttonurl = newsmap[?"buttonurl"]
                    if (!is_undefined(newsmap[?"saveclose"]))
                        iid = newsmap[?"id"]
                    else
                        iid = null
					
                    if (!iid || ds_list_find_index(closed_alerts, iid) < 0)
                        alert_show(title, text, icon, button, buttonurl, null, iid)
                }
            }
            ds_map_destroy(decoded)
        }
		else
            log("Failed to decode")
    }
}
