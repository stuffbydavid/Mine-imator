/// action_toolbar_exportmovie_save()

var fn;
switch (popup_exportmovie.format)
{
	case "mp4":	fn = file_dialog_save_movie_mp4(project_name);	break
	case "mov":	fn = file_dialog_save_movie_mov(project_name);	break
	case "wmv":	fn = file_dialog_save_movie_wmv(project_name);	break
	default:	fn = file_dialog_save_movie_png(project_name);	break
}
    
if (fn = "")
    return 0

// Start rendering
exportmovie_filename = fn
exportmovie_marker_previous = timeline_marker
exportmovie_format = popup_exportmovie.format
exportmovie_frame_rate = popup_exportmovie.frame_rate
exportmovie_high_quality = popup_exportmovie.high_quality

if (timeline_region_start != null)
{
    exportmovie_marker_start = timeline_region_start
    exportmovie_marker_end = timeline_region_end
}
else
{
    exportmovie_marker_start = 0
    exportmovie_marker_end = timeline_length
}

if (exportmovie_format != "png")
{
    var fmt = popup_exportmovie.format;
    if (fmt = "wmv")
        fmt = "asf"

    log("Export movie", fn)
    log("Format", exportmovie_format)
    log("Bitrate", popup_exportmovie.bit_rate)
    log("Framerate", exportmovie_frame_rate)
    log("Audio", yesno(popup_exportmovie.include_audio))
    log("High Quality", yesno(exportmovie_high_quality))
    log("Size", project_video_width, project_video_height)

    movie_set(project_video_width, project_video_height, popup_exportmovie.bit_rate, exportmovie_frame_rate, popup_exportmovie.include_audio)
    var err = movie_start(fn, fmt);
    if (err < 0)
	{
        log("Error when exporting, error code", err)
        error("errorexportmovie")
        render_hidden = false
        render_watermark = false
        return 0
    }
    
    // Add sounds
    if (popup_exportmovie.include_audio)
	{
        with (obj_resource)
		{
            if (type = "sound" && ready)
			{
                buffer_save(sound_buffer, temp_file)
                sound_file_id = movie_audio_file_add(temp_file)
                if (sound_file_id < 0)
				{
                    movie_done()
                    log("Error adding sound, error code", sound_file_id)
                    error("errorexportmovie")
                    return 0
                }
            }
        }
        
        with (obj_timeline)
		{
            if (type != "audio" || (hide && !render_hidden))
				continue
				
            for (var k = 0; k < keyframe_amount; k++)
			{
                with (keyframe[k])
				{
                    if (value[SOUNDOBJ] && value[SOUNDOBJ].ready && value[SOUNDVOLUME] > 0 &&
						pos < app.exportmovie_marker_end &&
						pos + tl_keyframe_length(id) >= app.exportmovie_marker_start)
					{
                        movie_audio_sound_add(value[SOUNDOBJ].sound_file_id, 
                                              max(0, pos - app.exportmovie_marker_start) / app.project_tempo, 
                                              value[SOUNDVOLUME], 
                                              value[SOUNDSTART] + max(0, app.exportmovie_marker_start - pos) / app.project_tempo, 
                                              value[SOUNDEND])
					}
				}
			}
		}
    }
    
    exportmovie_buffer = buffer_create(project_video_width * project_video_height * 4, buffer_fixed, 4)
    render_background = true
}
else
{
    log("Export image sequence", fn)
    log("Framerate", exportmovie_frame_rate)
    log("High Quality", yesno(exportmovie_high_quality))
    log("Size", project_video_width, project_video_height)
    
    render_background=!popup_exportmovie.remove_background
}

render_hidden = popup_exportmovie.include_hidden
render_watermark = setting_render_watermark

exportmovie = true
exportmovie_frame = 0
exportmovie_start = current_time

timeline_marker = exportmovie_marker_start
action_toolbar_play_start()
