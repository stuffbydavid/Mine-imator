#pragma shady: skip_compilation
void main() {}

#region PCSS_PLANE_LIB
#pragma shady: macro_begin PCSS_PLANE_LIB

// Solve the depth change along a receiver-plane tangent
float getPCSSAxisSlope(vec3 axis, vec3 tangent, vec3 depthAxis)
{
	float denom = dot(axis, tangent);
	float scale = length(axis) * length(tangent);
	// A collapsed axis has no usable slope
	if (scale == 0.0)
		return 0.0;

	// Limit the reciprocal near an edge-on receiver plane
	float minDenom = scale * 0.0001;
	float inverse = denom / (denom * denom + minDenom * minDenom);

	return dot(depthAxis, tangent) * inverse;
}

// Each tangent lies on the receiver plane and holds the other UV axis constant
vec2 getPCSSDepthSlope(vec3 xAxis, vec3 yAxis, vec3 depthAxis, vec3 normal)
{
	return vec2(
		getPCSSAxisSlope(xAxis, cross(yAxis, normal), depthAxis),
		getPCSSAxisSlope(yAxis, cross(normal, xAxis), depthAxis)
	);
}

// Orthographic shadow coordinates are linear in world position
vec2 getPCSSOrthoSlope(mat4 mat, vec3 normal)
{
	vec3 xAxis = vec3(mat[0][0], mat[1][0], mat[2][0]);
	vec3 yAxis = vec3(mat[0][1], mat[1][1], mat[2][1]);
	vec3 depthAxis = vec3(mat[0][2], mat[1][2], mat[2][2]);

	return getPCSSDepthSlope(xAxis, yAxis, depthAxis, normal);
}

// Perspective UV axes include the divide by light-space depth and flipped Y
vec2 getPCSSSpotSlope(mat4 mat, vec3 pos, vec3 normal)
{
	vec3 xAxis = vec3(mat[0][0], mat[1][0], mat[2][0]);
	vec3 yAxis = vec3(mat[0][1], mat[1][1], mat[2][1]);
	vec3 zAxis = vec3(mat[0][2], mat[1][2], mat[2][2]);

	// Differentiate projected UV analytically, without screen derivatives
	float depth = max(pos.z, 0.0001);
	xAxis = (xAxis - zAxis * (pos.x / depth)) * (0.5 / depth);
	yAxis = (yAxis - zAxis * (pos.y / depth)) * (-0.5 / depth);

	return getPCSSDepthSlope(xAxis, yAxis, zAxis, normal);
}

// Intersect a point-light sample ray with the receiver plane
float getPCSSRayDepth(vec3 direction, vec3 pos, vec3 normal, float fallback)
{
	float denom = dot(direction, normal);

	// A nearly parallel ray cannot provide a stable intersection
	if (abs(denom) < 0.0001)
		return fallback;

	float depth = dot(pos, normal) / denom;
	return depth > 0.0 ? depth : fallback;
}

#pragma shady: macro_end
#endregion

#region PCSS_LIB
#pragma shady: macro_begin PCSS_LIB

#define PCSS_MAX_SAMPLES 64
#define PCSS_MAX_BLOCKER_SAMPLES 16
#define PCSS_REFERENCE_SHADOW_SIZE 2048.0

// Bounds store the lower texel center in xy and upper texel center in zw
// Restrict the footprint to one map or one point-light atlas face
void getPCSSTexels(vec2 coord, vec2 size, vec2 low, vec2 high, out vec4 bounds, out vec2 blend)
{
	vec2 texel = clamp(coord * size - 0.5, low * size, high * size - 1.0);
	vec2 first = (floor(texel) + 0.5) / size;

	bounds = vec4(first, min(first + 1.0 / size, high - 0.5 / size));
	blend = fract(texel);
}

float blendPCSSVisibility(vec4 shadow, vec2 blend)
{
	// Compare depths first, then interpolate visibility across the two rows
	float bottom = mix(shadow.x, shadow.y, blend.x);
	float top = mix(shadow.z, shadow.w, blend.x);

	return mix(bottom, top, blend.y);
}

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
