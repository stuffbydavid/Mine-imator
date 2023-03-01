/// tl_supports_ik()

function tl_supports_ik()
{
	return ((type = e_tl_type.BODYPART && model_part != null && model_part.bend_part != null && model_part.bend_end_offset > 0 && model_part.bend_part = e_part.LOWER) &&
			(model_part.bend_axis[X] && !model_part.bend_axis[Y] && !model_part.bend_axis[Z]))
}