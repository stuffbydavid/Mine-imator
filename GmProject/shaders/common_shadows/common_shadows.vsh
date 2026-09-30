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
