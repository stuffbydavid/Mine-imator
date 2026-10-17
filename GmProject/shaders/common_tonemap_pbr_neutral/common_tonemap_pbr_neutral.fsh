#pragma shady: skip_compilation
void main(){}

#region TONEMAP_PBR_NEUTRAL_LIB
#pragma shady: macro_begin TONEMAP_PBR_NEUTRAL_LIB

// SPDX-License-Identifier: Apache-2.0
// Adapted from the Khronos PBR Neutral reference implementation
// Copyright 2023 The Khronos Group Inc.
// https://github.com/KhronosGroup/ToneMapping/blob/main/PBR_Neutral/pbrNeutral.glsl

vec3 mapPBRNeutral(vec3 color)
{
	color = max(color, vec3(0.0));
	float startCompression = 0.76;
	float desaturation = 0.15;
	float minimumChannel = min(color.r, min(color.g, color.b));
	float offset = minimumChannel < 0.08 ? minimumChannel - 6.25 * minimumChannel * minimumChannel : 0.04;
	color -= offset;

	float peak = max(color.r, max(color.g, color.b));
	if (peak < startCompression)
		return color;

	float distance = 1.0 - startCompression;
	float newPeak = 1.0 - distance * distance / (peak + distance - startCompression);
	color *= newPeak / peak;
	float desaturationWeight = 1.0 - 1.0 / (desaturation * (peak - newPeak) + 1.0);
	return mix(color, vec3(newPeak), desaturationWeight);
}

#pragma shady: macro_end
#endregion
