/// tl_update_values_progress()
/// @desc Updates the values.

function tl_update_values_progress()
{
	keyframe_progress = 0
	
	// Get regular progress
	if (!(app.timeline_repeat && app.timeline_seamless_repeat))
	{
		if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
			keyframe_progress = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position)
		
		return 0
	}
	
	// Calculate seamless looping by changing the 'next' keyframe
	var loopstart, loopend, seamlessloop;
	if (app.timeline_region_start != null)
	{
		loopstart = app.timeline_region_start
		loopend = app.timeline_region_end
	}
	else
	{
		loopstart = 0
		loopend = app.timeline_length
	}
	
	seamlessloop = (app.timeline_repeat && app.timeline_seamless_repeat && app.timeline_marker >= loopstart && app.timeline_marker < loopend)
	
	// Change keyframes so the animation is seamless
	var kflistsize, lastkf, loopnext, loopprev;
	kflistsize = ds_list_size(keyframe_list)
	lastkf = kflistsize - 1
	loopnext = false
	loopprev = false
		
	if (keyframe_next = keyframe_current || keyframe_next.position > loopend) // Continue into the first keyframe
	{
		// Get first keyframe in timeline region
		for (var k = 0; k < kflistsize; k++)
		{
			var kf = keyframe_list[|k];
				
			if (kf.position < loopstart || kf.position > loopend)
				continue
			else
			{
				if (kf.position < keyframe_next.position)
					keyframe_next = kf
			}
		}
			
		loopnext = true
	}
	else if (keyframe_current = null || keyframe_current.position < loopstart) // Continue from last keyframe
	{
		// Get last keyframe in timeline region
		for (var k = 0; k < kflistsize; k++)
		{
			var kf = keyframe_list[|k];
				
			if (kf.position < loopstart || kf.position > loopend)
				continue
			else
			{
				if (keyframe_current = null || kf.position > keyframe_current.position)
					keyframe_current = kf
			}
		}
			
		loopprev = true
	}
		
	// Get progress
	var regionsize = loopend - loopstart;
	if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
	{
		if (loopnext)
			keyframe_progress = (app.timeline_marker - keyframe_current.position) / ((keyframe_next.position + regionsize) - keyframe_current.position)
		else if (loopprev)
			keyframe_progress = ((app.timeline_marker + regionsize) - keyframe_current.position) / ((keyframe_next.position + regionsize) - keyframe_current.position)
		else
			keyframe_progress = (app.timeline_marker - keyframe_current.position) / (keyframe_next.position - keyframe_current.position)
	}
	else
		keyframe_current = keyframe_next
}
