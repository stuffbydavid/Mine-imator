/// render_pass_channel(pass)
/// @arg pass

function render_pass_channel(pass)
{
	switch (pass)
	{
		case e_render_pass.ROUGHNESS: return 1
		case e_render_pass.METALLIC: return 2
		case e_render_pass.FRESNEL: return 3
		case e_render_pass.EMISSIVE:
		case e_render_pass.SSAO_MASK: return 4
		case e_render_pass.BLOOM_THRESHOLD:
		case e_render_pass.BLOOM_BLUR: return 5
	}
	
	return 0
}