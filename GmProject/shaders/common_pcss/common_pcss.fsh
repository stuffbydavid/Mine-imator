#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin PCSS_COMMON_LIB

#pragma shady: inline(common_shadows.PCSS_LIB)

float getShadowMinimumRadius(float lightRadius, float sourceRadius, float receiverDepth, float bufferSize, float searchRadius)
{
	// Scale the footprint for the light projection and global blur amount
	float blurScale = lightRadius / max(sourceRadius, 0.0001);
	float minimumRadius = 2.0 * blurScale / min(bufferSize, PCSS_REFERENCE_SHADOW_SIZE);
	// Small or distant light sources can still produce sharp shadows
	float sourceFootprint = lightRadius / max(receiverDepth, 0.0001);
	return min(minimumRadius, min(sourceFootprint, searchRadius));
}

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

#pragma shady: macro_end

#pragma shady: macro_begin PCSS_FILTER_LIB

// Each light supplies ShadowReceiver and its depth/texel lookups
float getShadowBlockerDepth(ShadowReceiver receiver, float sampleDepth, float surfaceDepth)
{
	// Keep sampled depths comparable on sloped receivers
	if (receiver.perspective)
		return sampleDepth * receiver.depth / max(surfaceDepth, 0.0001);
	return sampleDepth - (surfaceDepth - receiver.depth);
}

bool tryGetShadowBlockerDepth(ShadowReceiver receiver, vec2 offset, out float blockerDepth)
{
	float surfaceDepth;
	float sampleDepth = getShadowSampleDepth(receiver, offset, surfaceDepth);
	blockerDepth = getShadowBlockerDepth(receiver, sampleDepth, surfaceDepth);

	return isPCSSBlocker(surfaceDepth, sampleDepth, receiver.bias);
}

float getShadowFilterRadius(ShadowReceiver receiver, float blockerDepth, float minimumRadius)
{
	// Bias should not increase blur
	float separation = max(receiver.depth - blockerDepth - receiver.bias, 0.0);
	float radius = receiver.lightRadius * separation;
	if (receiver.perspective)
		radius /= max(blockerDepth, receiver.nearDepth);

	return clamp(radius * receiver.radiusScale, minimumRadius, receiver.searchRadius);
}

float getShadowVisibility(ShadowReceiver receiver, vec2 offset)
{
	float surfaceDepth;
	float sampleDepth = getShadowSampleDepth(receiver, offset, surfaceDepth);
	return getPCSSVisibility(surfaceDepth, sampleDepth, receiver.bias);
}

float filterShadow(ShadowReceiver receiver, float radius, int samples)
{
	if (radius <= 0.0)
		return getShadowVisibility(receiver, vec2(0.0));

	float visibility = 0.0;
	for (int i = 0; i < PCSS_MAX_SAMPLES; i++)
	{
		if (i >= samples)
			break;

		vec2 offset = uPCSSKernel[i] * radius;
		visibility += getShadowVisibility(receiver, offset);
	}

	return visibility / float(samples);
}

bool findShadowBlockerDepth(
	ShadowReceiver receiver, int samples, float minimumRadius,
	float centerDepth, float surfaceDepth, out float blockerDepth
)
{
	float depthSum = 0.0;
	float blockers = 0.0;
	// Reuse the center lookup to retain thin shadows
	if (isPCSSBlocker(surfaceDepth, centerDepth, receiver.bias))
	{
		depthSum = getShadowBlockerDepth(receiver, centerDepth, surfaceDepth);
		blockers = 1.0;
	}

	int localSamples = (samples + 1) / 2;
	float searchRadius = receiver.localRadius;
	float radiusGrowth = 1.0;
	if (blockers == 0.0 && searchRadius > 0.0)
		radiusGrowth = pow(max(receiver.searchRadius / searchRadius, 1.0), 1.0 / float(samples - localSamples));

	// Share one sample budget between nearby search, wider search and refinement
	for (int i = 0; i < PCSS_MAX_BLOCKER_SAMPLES; i++)
	{
		if (i >= samples)
			break;

		if (i >= localSamples)
		{
			searchRadius = min(searchRadius * radiusGrowth, receiver.searchRadius);
			if (i == samples - 1 || searchRadius <= 0.0)
				searchRadius = receiver.searchRadius;
		}

		float radius = searchRadius;
		if (blockers > 0.0)
			radius = getShadowFilterRadius(receiver, depthSum / blockers, minimumRadius);

		float sampleDepth;
		if (tryGetShadowBlockerDepth(receiver, uPCSSKernel[i] * radius, sampleDepth))
		{
			depthSum += sampleDepth;
			blockers += 1.0;
		}
	}

	if (blockers == 0.0)
	{
		blockerDepth = receiver.depth;
		return false;
	}

	blockerDepth = depthSum / blockers;
	return true;
}

float getPCSSShadow(ShadowReceiver receiver, int quality, float minimumRadius, float centerDepth, float surfaceDepth)
{
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;
	int samples = getPCSSBlockerSamples(quality);

	float blockerDepth;
	if (!findShadowBlockerDepth(receiver, samples, minimumRadius, centerDepth, surfaceDepth, blockerDepth))
		return getPCSSVisibility(surfaceDepth, centerDepth, receiver.bias);

	float radius = getShadowFilterRadius(receiver, blockerDepth, minimumRadius);
	if (radius <= 0.0)
		return getPCSSVisibility(surfaceDepth, centerDepth, receiver.bias);

	return filterShadow(receiver, radius, quality);
}

#pragma shady: macro_end
