#pragma shady: skip_compilation
void main() {}

#region PCSS_PLANE_LIB
#pragma shady: macro_begin PCSS_PLANE_LIB

// Find how depth changes along one direction on the surface
float getPCSSAxisSlope(vec3 axis, vec3 tangent, vec3 depthAxis)
{
	float denom = dot(axis, tangent);
	float scale = length(axis) * length(tangent);
	// No slope if either direction has zero length
	if (scale == 0.0)
		return 0.0;

	// Keep the slope stable when the surface is almost edge-on
	float minDenom = scale * 0.0001;
	float inverse = denom / (denom * denom + minDenom * minDenom);

	return dot(depthAxis, tangent) * inverse;
}

// Find how depth changes across the shadow map
vec2 getPCSSDepthSlope(vec3 xAxis, vec3 yAxis, vec3 depthAxis, vec3 normal)
{
	return vec2(
		getPCSSAxisSlope(xAxis, cross(yAxis, normal), depthAxis),
		getPCSSAxisSlope(yAxis, cross(normal, xAxis), depthAxis)
	);
}

// Read the matrix consistently in GLSL and HLSL
void getPCSSProjectionAxes(mat4 mat, out vec3 xAxis, out vec3 yAxis, out vec3 zAxis)
{
	vec3 xColumn = (mat * vec4(1.0, 0.0, 0.0, 0.0)).xyz;
	vec3 yColumn = (mat * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	vec3 zColumn = (mat * vec4(0.0, 0.0, 1.0, 0.0)).xyz;

	xAxis = vec3(xColumn.x, yColumn.x, zColumn.x);
	yAxis = vec3(xColumn.y, yColumn.y, zColumn.y);
	zAxis = vec3(xColumn.z, yColumn.z, zColumn.z);
}

// Surface slope for sun shadows
vec2 getPCSSOrthoSlope(mat4 mat, vec3 normal)
{
	vec3 xAxis, yAxis, depthAxis;
	getPCSSProjectionAxes(mat, xAxis, yAxis, depthAxis);

	return getPCSSDepthSlope(xAxis, yAxis, depthAxis, normal);
}

// Surface slope for spot shadows
vec2 getPCSSSpotSlope(mat4 mat, vec3 pos, vec3 normal)
{
	vec3 xAxis, yAxis, zAxis;
	getPCSSProjectionAxes(mat, xAxis, yAxis, zAxis);

	// Adjust for perspective and the flipped Y axis
	float depth = max(pos.z, 0.0001);
	xAxis = (xAxis - zAxis * (pos.x / depth)) * (0.5 / depth);
	yAxis = (yAxis - zAxis * (pos.y / depth)) * (-0.5 / depth);

	return getPCSSDepthSlope(xAxis, yAxis, zAxis, normal);
}

// Find where the sample ray hits the surface
float getPCSSRayDepth(vec3 direction, vec3 pos, vec3 normal, float fallback)
{
	float denom = dot(direction, normal);

	// Use the original depth if the ray is almost parallel to the surface
	if (abs(denom) < 0.0001)
		return fallback;

	float depth = dot(pos, normal) / denom;
	return depth > 0.0 ? depth : fallback;
}

#pragma shady: macro_end
#endregion
