/// tl_update_values_progress(markerpos)
/// @desc Updates the values.

function tl_update_values_progress(markerpos)
{
	var kflength, kfprogress;
	var progress = 0;
	
	// Get regular progress
	if (!app.timeline_seamless_repeat)
	{
		if (keyframe_current && keyframe_next && keyframe_current != keyframe_next)
		{
			kflength = (markerpos - keyframe_current.position)
			kfprogress = (keyframe_next.position - keyframe_current.position)
			
			progress = kflength / kfprogress
		}
		
		return progress
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
	
	seamlessloop = (app.timeline_seamless_repeat && markerpos >= loopstart && markerpos < loopend)
	
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
		var range = keyframe_next.position - keyframe_current.position;
		if (loopnext)
			range += regionsize;
		else if (loopprev)
		{
			markerpos += regionsize;
			range += regionsize;
		}
		
		if (range != 0)
			progress = (markerpos - keyframe_current.position) / range;
	}
	else
		keyframe_current = keyframe_next
	
	return progress
}
