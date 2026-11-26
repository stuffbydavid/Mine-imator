function action_tl_frame_cam_fx_bloom_amount(value, add)
{
	var oldamount, amount, threshold;
	oldamount = tl_edit.value[e_value.CAM_FX_BLOOM_INTENSITY] * 100
	amount = max(0, add ? oldamount + value : value)
	
	// Calculate threshold from amount, between 0.5 and 0.85
	if (amount <= 100)
		threshold = 0.85
	else if (amount <= 200)
		threshold = lerp(0.85, 0.75, (amount - 100) / 100)
	else if (amount <= 300)
		threshold = lerp(0.75, 0.6, (amount - 200) / 100)
	else if (amount <= 500)
		threshold = lerp(0.6, 0.55, (amount - 300) / 200)
	else
		threshold = 0.5 + 25 / amount

	tl_value_set_start(action_tl_frame_cam_fx_bloom_amount, true)
	tl_value_set(e_value.CAM_FX_BLOOM_INTENSITY, (add ? amount - oldamount : amount) / 100, add)
	tl_value_set(e_value.CAM_FX_BLOOM_THRESHOLD, threshold)
	tl_value_set_done()
}
