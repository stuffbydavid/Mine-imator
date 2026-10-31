/// action_setting_timeline_audio_scrub(enable)
/// @arg enable

function action_setting_timeline_audio_scrub(enable)
{
	setting_timeline_audio_scrub = enable

	if (!enable)
		tl_audio_scrub_end(true)
}
