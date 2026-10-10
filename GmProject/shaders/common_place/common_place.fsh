#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin PLACE_FRAGMENT_LIB

vec4 getPlaceColor(vec3 color, vec3 localNormal)
{
	// Direction ID from local normal
	vec3 normal = abs(localNormal);
	float direction = localNormal.x < 0.0 ? 1.0 : 0.0;
	if (normal.y > normal.x)
		direction = localNormal.y < 0.0 ? 3.0 : 2.0;
	if (normal.z > max(normal.x, normal.y))
		direction = localNormal.z < 0.0 ? 5.0 : 4.0;
	
	return vec4(color, direction / 255.0);
}

#pragma shady: macro_end
