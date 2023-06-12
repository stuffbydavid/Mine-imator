/// tl_supports_ik(typeinit)

function tl_supports_ik(typeinit = true)
{
	if (!typeinit) {
		return (
			(bend_end_offset > 0) &&
			(
				(bend_part = e_part.LOWER) &&
				(bend_axis[X] && !bend_axis[Y] && !bend_axis[Z])
			)
		)
	}
	return (
		(type = e_tl_type.BODYPART && model_part != null && model_part.bend_part != null && model_part.bend_end_offset > 0) &&
		(
			(model_part.bend_part = e_part.LOWER) &&
			(model_part.bend_axis[X] && !model_part.bend_axis[Y] && !model_part.bend_axis[Z])
		)
	)
}