/// @arg effecttype

function camera_effect_type_use_aperture(fxtype)
{
	return (fxtype = e_cam_fx.BLOOM || fxtype = e_cam_fx.DOF)
}
