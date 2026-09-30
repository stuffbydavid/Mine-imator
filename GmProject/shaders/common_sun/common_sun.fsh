#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin SUN_LIB

#define NUM_CASCADES 3

uniform vec3 uLightDirection; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uSunNear[NUM_CASCADES]; // static
uniform float uSunFar[NUM_CASCADES]; // static
uniform float uCascadeWorldSize[NUM_CASCADES]; // static

uniform sampler2D uDepthBuffer0; // static pass_uv depth_uv
uniform sampler2D uDepthBuffer1; // static pass_uv depth_uv
uniform sampler2D uDepthBuffer2; // static pass_uv depth_uv
uniform float uCascadeEndClipSpace[NUM_CASCADES]; // static
uniform int uCascadeCount; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static
uniform float uSunShadowDistance; // static
uniform float uSunShadowScale; // static
uniform float uDepthBufferSize; // static
uniform vec2 uScreenSize; // static

uniform vec3 uSSSRadius;
uniform float uLightSpecular;
uniform float uSunAngularRadius;

varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying vec2 vDepthSlope0;
varying vec2 vDepthSlope1;
varying vec2 vDepthSlope2;
varying vec4 vClipPosition;
varying float vClipSpaceDepth;

#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_shadows.PCSS_LIB)

float cascadeDepthBuffer(int index, vec2 coord)
{
	if (index == 0)
		return texture2D(uDepthBuffer0, coord).r;
	else if (index == 1)
		return texture2D(uDepthBuffer1, coord).r;
	else
		return texture2D(uDepthBuffer2, coord).r;
}

float getSunDepth(int cascade, vec2 coord, float range)
{
	return uSunNear[cascade] + cascadeDepthBuffer(cascade, coord) * range;
}

float getSunVisibility(int cascade, vec2 coord, float depth, vec2 sampleCoord, vec2 slope, float range, float bias)
{
	float receiverDepth = getPCSSReceiverDepth(coord, depth, sampleCoord, slope);
	return getPCSSVisibility(receiverDepth, getSunDepth(cascade, sampleCoord, range), bias);
}

// Bilinearly weight the four depth comparisons around a filter sample
float getSunFilteredVisibility(int cascade, vec2 coord, float depth, vec2 sampleCoord, vec2 slope, float range, float bias)
{
	vec4 bounds;
	vec2 blend;
	getPCSSTexels(sampleCoord, vec2(uDepthBufferSize), vec2(0.0), vec2(1.0), bounds, blend);

	// Sample each texel independently so depth discontinuities stay intact
	vec4 shadow;
	shadow.x = getSunVisibility(cascade, coord, depth, bounds.xy, slope, range, bias);
	shadow.y = getSunVisibility(cascade, coord, depth, bounds.zy, slope, range, bias);
	shadow.z = getSunVisibility(cascade, coord, depth, bounds.xw, slope, range, bias);
	shadow.w = getSunVisibility(cascade, coord, depth, bounds.zw, slope, range, bias);

	return blendPCSSVisibility(shadow, blend);
}

float getSunShadow(
	int cascade, vec2 coord, float fragDepth, float depthRange,
	vec2 depthSlope, float bias,
	out float centerDepth
)
{
	int quality = uShadowBlurQuality;
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;

	centerDepth = getSunDepth(cascade, coord, depthRange);
	
	if (quality <= 0 || uSunShadowScale <= 0.000001)
		return getPCSSVisibility(fragDepth, centerDepth, bias);

	// The kernel rotates between accumulated samples, not between neighboring pixels
	int blockerSamples = getPCSSBlockerSamples(quality);
	
	// Convert world-space penumbra sizes to this cascade's texture coordinates
	float inverseWorldSize = 1.0 / max(uCascadeWorldSize[cascade], 0.0001);
	
	// Scale the minimum world-space blur with the setting across all cascades
	float blurSize = uSunShadowScale / max(uSunAngularRadius, 0.000001);
	float filterWorldSize = uCascadeWorldSize[0];
	
	// Use the near split as reference even when one cascade covers the full range
	if (uCascadeCount == 1)
		filterWorldSize *= min(1.0, max(300.0, uSunShadowDistance * 0.1) / max(uSunShadowDistance, 0.0001));
	
	float minimumFilterRadius = blurSize * filterWorldSize / PCSS_REFERENCE_SHADOW_SIZE * inverseWorldSize;
	float searchWorldRadius = uSunShadowScale * uSunShadowDistance;
	float searchRadius = max(searchWorldRadius * inverseWorldSize, minimumFilterRadius);
	
	// Always include the center so sparse searches cannot miss narrow shadows
	float blockers = isPCSSBlocker(fragDepth, centerDepth, bias) ? 1.0 : 0.0;
	float blockerDepth = centerDepth * blockers;

	// Blocker search
	for (int blockerIndex = 0; blockerIndex < PCSS_MAX_BLOCKER_SAMPLES; blockerIndex++)
	{
		if (blockerIndex >= blockerSamples)
			break;

		vec2 sampleCoord = clamp(coord + uPCSSKernel[blockerIndex] * searchRadius, vec2(0.0), vec2(1.0));
		float sampleDepth = getSunDepth(cascade, sampleCoord, depthRange);
		float receiverDepth = getPCSSReceiverDepth(coord, fragDepth, sampleCoord, depthSlope);
		if (isPCSSBlocker(receiverDepth, sampleDepth, bias))
		{
			blockerDepth += sampleDepth - (receiverDepth - fragDepth);
			blockers += 1.0;
		}
	}

	if (blockers == 0.0)
		return 1.0;

	blockerDepth /= blockers;

	// Get penumbra for filter
	float separation = max(fragDepth - blockerDepth - bias, 0.0); // Ignore the bias gap
	float filterRadius = max(min(uSunShadowScale * separation, searchWorldRadius) * inverseWorldSize, minimumFilterRadius);
	float visibility = 0.0;

	// Filter shadow
	for (int filterIndex = 0; filterIndex < PCSS_MAX_SAMPLES; filterIndex++)
	{
		if (filterIndex >= quality)
			break;

		vec2 sampleCoord = clamp(coord + uPCSSKernel[filterIndex] * filterRadius, vec2(0.0), vec2(1.0));
		visibility += getSunFilteredVisibility(cascade, coord, fragDepth, sampleCoord, depthSlope, depthRange, bias);
	}

	return visibility / float(quality);
}

void getSunLighting(
	vec4 baseColor, vec3 normal,
	float roughness, float metallic,
	float F0, float sss,
	out vec3 light, out vec3 spec
)
{
	light = vec3(0.0);
	spec = vec3(0.0);
	
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	if (uIsSky == 0)
	{
		vec3 subsurfaceRadius = uSSSRadius * sss;
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, uLightDirection, uCameraPosition, vPosition, specularF0);

		// Diffuse factor
		float dif = clamp(max(0.0, dot(normal, uLightDirection)), 0.0, 1.0);

		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);

		if (dif > 0.0 || sss > 0.0)
		{
			// Find the cascade to use
			int i;
			for (i = 0; i < uCascadeCount; i++)
				if (vClipSpaceDepth < uCascadeEndClipSpace[i])
					break;
			bool cascadeValid = i < uCascadeCount;
			if (i >= uCascadeCount)
				i = uCascadeCount - 1;

			vec4 screenCoord;
			vec2 depthSlope;
			float bias;
			if (i == 0)
			{
				screenCoord = vScreenCoord0;
				depthSlope = vDepthSlope0;
				bias = 1.0;
			}
			else if (i == 1)
			{
				screenCoord = vScreenCoord1;
				depthSlope = vDepthSlope1;
				bias = 3.0;
			}
			else
			{
				i = 2;
				screenCoord = vScreenCoord2;
				depthSlope = vDepthSlope2;
				bias = 6.0;
			}

			float fragDepth = screenCoord.z;
			vec2 fragCoord = screenCoord.xy;

			// Texture position must be valid
			if (cascadeValid && fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0)
			{
				// Convert 0->1 to Near->Far
				float depthRange = uSunFar[i] - uSunNear[i];
				fragDepth = uSunNear[i] + fragDepth * depthRange;
				depthSlope *= depthRange;

				// Find shadow
				float sampleDepth;
				shadow *= vec3(getSunShadow(i, fragCoord, fragDepth, depthRange, depthSlope, bias, sampleDepth));

				// Subsurface translucency
				if (sss > 0.0 && dif == 0.0)
					subsurf += getSubsurfaceTranslucency(fragDepth, sampleDepth, subsurfaceRadius);
			}
		}

		// Diffuse light
		light = lightCol * dif * shadow;

		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, uLightDirection, lightCol, uCameraPosition, vPosition, sss, 1.0);

		light *= (vec3(1.0) - F) * (1.0 - metallic);

		// Calculate specular
		if (uLightSpecular * dif * shadow.r > 0.0)
		{
			float diskNormalization;
			vec3 diskLightDir = getSphereLightDirection(normal, uCameraPosition, vPosition, uLightDirection, uSunAngularRadius, roughness, diskNormalization);
			vec3 specular = getSpecular(normal, diskLightDir, uCameraPosition, vPosition, specularF0, roughness) * diskNormalization;
			spec = lightCol * uLightSpecular * dif * shadow * specular;
		}
	}
}
#pragma shady: macro_end
