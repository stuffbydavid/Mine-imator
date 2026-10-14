#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin PLACE_LIB

#define PLACE_DIR_NONE		6
#define PLACE_ID_SCALE		2097152.0 // 2^21
#define PLACE_TYPE_SCENE	0
#define PLACE_TYPE_PLACED	1
#define PLACE_TYPE_BLOCK	2
#define PLACE_TYPE_CLOUDS	3

uniform int uRenderPlace; // static
uniform int uPlaceType;
uniform int uPlaceId;

varying vec3 vPlaceNormal;

float getPlaceIndex()
{
	// Clouds write background depth/face value
	if (uPlaceType == PLACE_TYPE_CLOUDS)
		return float(PLACE_DIR_NONE) * PLACE_ID_SCALE;
	
	// Don't process placed object
	if (uPlaceType == PLACE_TYPE_PLACED)
		return 0.0;

	// Direction ID from local normal
	vec3 normal = abs(vPlaceNormal);
	float dir = vPlaceNormal.x < 0.0 ? 1.0 : 0.0;
	if (normal.y > normal.x)
		dir = vPlaceNormal.y < 0.0 ? 3.0 : 2.0;
	if (normal.z > max(normal.x, normal.y))
		dir = vPlaceNormal.z < 0.0 ? 5.0 : 4.0;
	
	return float(uPlaceId) + dir * PLACE_ID_SCALE;
}

vec4 getPlaceOutput(float viewDistance, float nearPlane, float farPlane)
{
	// R stores linear depth, G stores the ID and local face ID
	float depth = (viewDistance - nearPlane) / (farPlane - nearPlane);
	float alpha = (uPlaceType == PLACE_TYPE_PLACED ? 0.0 : 1.0); // Alpha 0 for object being placed
	return vec4(depth, getPlaceIndex(), 0.0, alpha);
}

#pragma shady: macro_end
