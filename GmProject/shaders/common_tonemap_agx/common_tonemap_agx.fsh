#pragma shady: skip_compilation
void main(){}

#region TONEMAP_AGX_LIB
#pragma shady: macro_begin TONEMAP_AGX_LIB

// SPDX-License-Identifier: Apache-2.0
// Adapted from Google Filament's AgX tone mapper
// Copyright 2021 The Android Open Source Project
// https://github.com/google/filament/blob/main/filament/src/ToneMapper.cpp

vec3 agxDefaultContrastApprox(vec3 value)
{
	vec3 value2 = value * value;
	vec3 value4 = value2 * value2;
	vec3 value6 = value4 * value2;
	return -17.86 * value6 * value
		+ 78.01 * value6
		- 126.7 * value4 * value
		+ 92.06 * value4
		- 28.72 * value2 * value
		+ 4.361 * value2
		- 0.1718 * value
		+ 0.002857;
}

vec3 agxPunchyLook(vec3 value)
{
	float luminance = dot(value, vec3(0.2126, 0.7152, 0.0722));
	value = pow(max(value, vec3(0.0)), vec3(1.35));
	return vec3(luminance) + 1.4 * (value - vec3(luminance));
}

vec3 mapAgX(vec3 color, int look)
{
	color = max(color, vec3(0.0));

	// Linear Rec. 709 to linear Rec. 2020
	color = vec3(
		color.r * 0.6274 + color.g * 0.3293 + color.b * 0.0433,
		color.r * 0.0691 + color.g * 0.9195 + color.b * 0.0113,
		color.r * 0.0164 + color.g * 0.0880 + color.b * 0.8956
	);

	color = vec3(
		color.r * 0.856627153315983 + color.g * 0.0951212405381588 + color.b * 0.0482516061458583,
		color.r * 0.137318972929847 + color.g * 0.761241990602591 + color.b * 0.101439036467562,
		color.r * 0.11189821299995 + color.g * 0.0767994186031903 + color.b * 0.811302368396859
	);

	color = log2(max(color, vec3(1.0e-10)));
	color = clamp((color + 12.47393) / 16.499999, 0.0, 1.0);
	color = agxDefaultContrastApprox(color);
	if (look == 1) // Punchy
		color = agxPunchyLook(color);

	color = vec3(
		color.r * 1.1271005818144368 + color.g * -0.11060664309660323 + color.b * -0.016493938717834573,
		color.r * -0.1413297634984383 + color.g * 1.157823702216272 + color.b * -0.016493938717834257,
		color.r * -0.14132976349843826 + color.g * -0.11060664309660294 + color.b * 1.2519364065950405
	);
	color = pow(max(color, vec3(0.0)), vec3(2.2));

	// Linear Rec. 2020 to linear Rec. 709
	return vec3(
		color.r * 1.6605 + color.g * -0.5876 + color.b * -0.0728,
		color.r * -0.1246 + color.g * 1.1329 + color.b * -0.0083,
		color.r * -0.0182 + color.g * -0.1006 + color.b * 1.1187
	);
}

#pragma shady: macro_end
#endregion
