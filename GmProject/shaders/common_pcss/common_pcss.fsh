#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin PCSS_COMMON_LIB

#pragma shady: inline(common_shadows.PCSS_LIB)

uniform float uShadowSmootherBlur; // static

vec2 getShadowTexelCoord(vec2 coord, vec2 size, vec2 mapMin, vec2 mapMax)
{
	vec2 texel = clamp(floor(coord * size), mapMin * size, mapMax * size - 1.0);
	return (texel + 0.5) / size;
}

float getShadowPerspectiveDepth(vec2 centerCoord, float centerDepth, vec2 sampleCoord, vec2 depthSlope)
{
	// Account for perspective on sloped surfaces
	float depthChange = dot(sampleCoord - centerCoord, depthSlope) / max(centerDepth, 0.0001);
	float denom = 1.0 - depthChange;
	return denom > 0.0001 ? centerDepth / denom : centerDepth;
}

#pragma shady: macro_end

#pragma shady: macro_begin PCSS_PROJECTED_LIB

float getShadowReceiverDepth(ShadowReceiver receiver, vec2 sampleCoord)
{
	if (receiver.perspective)
		return getShadowPerspectiveDepth(receiver.coord, receiver.depth, sampleCoord, receiver.depthSlope);
	return getPCSSReceiverDepth(receiver.coord, receiver.depth, sampleCoord, receiver.depthSlope);
}

float getShadowSampleDepth(ShadowReceiver receiver, vec2 offset, out float surfaceDepth)
{
	vec2 texelCoord = getShadowTexelCoord(receiver.coord + offset, vec2(uDepthBufferSize), vec2(0.0), vec2(1.0));
	surfaceDepth = getShadowReceiverDepth(receiver, texelCoord);
	return getShadowMapDepth(receiver, texelCoord);
}

void getShadowFilterTexels(ShadowReceiver receiver, vec2 offset, out vec4 bounds, out vec2 blend, out vec2 mapMin)
{
	mapMin = vec2(0.0);
	getPCSSTexels(receiver.coord + offset, vec2(uDepthBufferSize), mapMin, vec2(1.0), bounds, blend);
}

float getShadowTexelVisibility(ShadowReceiver receiver, vec2 texelCoord, vec2 mapMin)
{
	float depth = getShadowReceiverDepth(receiver, texelCoord);
	return getPCSSVisibility(depth, getShadowMapDepth(receiver, texelCoord), receiver.bias);
}

#pragma shady: macro_end

#pragma shady: macro_begin PCSS_FILTER_LIB

// Each light supplies ShadowReceiver and its depth/texel lookups
bool tryGetShadowBlockerDepth(ShadowReceiver receiver, vec2 offset, out float blockerDepth)
{
	float surfaceDepth;
	float sampleDepth = getShadowSampleDepth(receiver, offset, surfaceDepth);
	float depth = receiver.depth;

	// Keep sampled depths comparable on sloped receivers
	if (receiver.perspective)
		blockerDepth = sampleDepth * depth / max(surfaceDepth, 0.0001);
	else
		blockerDepth = sampleDepth - (surfaceDepth - depth);

	return isPCSSBlocker(surfaceDepth, sampleDepth, receiver.bias);
}

void findShadowBlockers(ShadowReceiver receiver, float searchRadius, int samples, out float depthSum, out float blockers)
{
	depthSum = 0.0;
	blockers = 0.0;
	for (int i = 0; i < PCSS_MAX_BLOCKER_SAMPLES; i++)
	{
		if (i >= samples)
			break;

		float blockerDepth;
		vec2 offset = uPCSSKernel[i] * searchRadius;
		if (tryGetShadowBlockerDepth(receiver, offset, blockerDepth))
		{
			depthSum += blockerDepth;
			blockers += 1.0;
		}
	}
}

float getShadowFilteredVisibility(ShadowReceiver receiver, vec2 offset)
{
	if (uShadowSmootherBlur <= 0.0)
	{
		float surfaceDepth;
		float sampleDepth = getShadowSampleDepth(receiver, offset, surfaceDepth);
		return getPCSSVisibility(surfaceDepth, sampleDepth, receiver.bias);
	}

	vec4 bounds;
	vec2 blend, mapMin;
	getShadowFilterTexels(receiver, offset, bounds, blend, mapMin);
	// Narrow the transition when global blur is below 100%
	blend = clamp((blend - 0.5) / uShadowSmootherBlur + 0.5, 0.0, 1.0);

	vec4 visibility;
	visibility.x = getShadowTexelVisibility(receiver, bounds.xy, mapMin);
	visibility.y = getShadowTexelVisibility(receiver, bounds.zy, mapMin);
	visibility.z = getShadowTexelVisibility(receiver, bounds.xw, mapMin);
	visibility.w = getShadowTexelVisibility(receiver, bounds.zw, mapMin);

	return blendPCSSVisibility(visibility, blend);
}

float filterShadow(ShadowReceiver receiver, float radius, int samples)
{
	if (radius <= 0.0)
		return getShadowFilteredVisibility(receiver, vec2(0.0));

	float visibility = 0.0;
	for (int i = 0; i < PCSS_MAX_SAMPLES; i++)
	{
		if (i >= samples)
			break;

		vec2 offset = uPCSSKernel[i] * radius;
		visibility += getShadowFilteredVisibility(receiver, offset);
	}

	return visibility / float(samples);
}

bool findShadowBlockerDepth(ShadowReceiver receiver, int samples, out float blockerDepth)
{
	int localSamples = samples;
	if (localSamples > 8)
		localSamples = 8;
	float localRadius = receiver.localRadius;
	float searchRadius = receiver.searchRadius;

	// Search nearby before widening the radius
	float depthSum, blockers;
	findShadowBlockers(receiver, localRadius, localSamples, depthSum, blockers);
	float centerDepth;
	if (tryGetShadowBlockerDepth(receiver, vec2(0.0), centerDepth))
	{
		depthSum += centerDepth;
		blockers += 1.0;
	}

	// Fill the gap between small and large searches
	if (blockers == 0.0 && searchRadius > localRadius * 2.0)
	{
		float midRadius = sqrt(localRadius * searchRadius);
		findShadowBlockers(receiver, midRadius, samples, depthSum, blockers);
	}
	if (blockers == 0.0 && searchRadius > localRadius)
		findShadowBlockers(receiver, searchRadius, samples, depthSum, blockers);

	if (blockers == 0.0)
	{
		blockerDepth = receiver.depth;
		return false;
	}

	blockerDepth = depthSum / blockers;
	return true;
}

float getShadowFilterRadius(ShadowReceiver receiver, float blockerDepth)
{
	// Bias should not increase blur
	float separation = max(receiver.depth - blockerDepth - receiver.bias, 0.0);
	float radius = receiver.lightRadius * separation;
	if (receiver.perspective)
		radius /= max(blockerDepth, receiver.nearDepth);

	return clamp(radius * receiver.radiusScale, 0.0, receiver.searchRadius);
}

float getPCSSShadow(ShadowReceiver receiver, int quality)
{
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;
	int samples = getPCSSBlockerSamples(quality);

	float blockerDepth;
	if (!findShadowBlockerDepth(receiver, samples, blockerDepth))
		return getShadowFilteredVisibility(receiver, vec2(0.0));

	float radius = getShadowFilterRadius(receiver, blockerDepth);

	// Refine at the radius used by the filter
	float refinedSum, refinedBlockers;
	findShadowBlockers(receiver, radius, samples, refinedSum, refinedBlockers);
	if (refinedBlockers > 0.0)
		radius = getShadowFilterRadius(receiver, refinedSum / refinedBlockers);

	return filterShadow(receiver, radius, quality);
}

#pragma shady: macro_end
