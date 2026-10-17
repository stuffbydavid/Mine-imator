#pragma shady: skip_compilation
void main() {}

#region PCSS_LIB
#pragma shady: macro_begin PCSS_LIB

#define PCSS_MAX_SAMPLES 64
#define PCSS_MAX_BLOCKER_SAMPLES 16
#define PCSS_REFERENCE_SHADOW_SIZE 2048.0

// Get samples used to find blockers
int getPCSSBlockerSamples(int filterSamples)
{
	int blockerSamples = (filterSamples + 1) / 2;
	
	if (blockerSamples < 4)
		blockerSamples = 4;
	
	if (blockerSamples > PCSS_MAX_BLOCKER_SAMPLES)
		blockerSamples = PCSS_MAX_BLOCKER_SAMPLES;
	
	return blockerSamples;
}

// Get a rotated disk sample
vec2 getPCSSSampleOffset(int index, vec2 rotation)
{
	vec2 offset = uPCSSKernel[index];
	return vec2(
		offset.x * rotation.x - offset.y * rotation.y,
		offset.x * rotation.y + offset.y * rotation.x
	);
}

// Get rotation for a screen pixel
vec2 getPCSSPixelRotation(vec4 clipPosition, vec2 screenSize)
{
	vec2 screenCoord = floor((clipPosition.xy / clipPosition.w * 0.5 + 0.5) * screenSize);
	float noise = fract(52.9829189 * fract(dot(screenCoord, vec2(0.06711056, 0.00583715))));
	float angle = noise * 6.28318531;
	return vec2(cos(angle), sin(angle));
}

// Get the receiver depth slope
vec2 getPCSSReceiverDepthGradient(vec2 coord, float depth)
{
	vec2 coordDx = dFdx(coord);
	vec2 coordDy = dFdy(coord);
	float depthDx = dFdx(depth);
	float depthDy = dFdy(depth);
	float determinant = coordDx.x * coordDy.y - coordDx.y * coordDy.x;
	float coordScale = length(coordDx) * length(coordDy);
	
	if (coordScale == 0.0)
		return vec2(0.0);
	
	// Keep the gradient stable
	float minDeterminant = coordScale * 0.0001;
	float inverseDeterminant = determinant / (determinant * determinant + minDeterminant * minDeterminant);
	
	return vec2(
		(depthDx * coordDy.y - depthDy * coordDx.y) * inverseDeterminant,
		(coordDx.x * depthDy - coordDy.x * depthDx) * inverseDeterminant
	);
}

// Get receiver depth at a sample
float getPCSSReceiverDepth(vec2 centerCoord, float centerDepth, vec2 sampleCoord, vec2 depthGradient)
{
	return centerDepth + dot(sampleCoord - centerCoord, depthGradient);
}

// Check if a sample blocks the light
bool isPCSSBlocker(float receiverDepth, float sampleDepth, float bias)
{
	return (receiverDepth - bias) > sampleDepth;
}

// Convert the depth test to visibility
float getPCSSVisibility(float receiverDepth, float sampleDepth, float bias)
{
	return isPCSSBlocker(receiverDepth, sampleDepth, bias) ? 0.0 : 1.0;
}

#pragma shady: macro_end
#endregion
