uniform sampler2D uTexture; // static

uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

#pragma shady: inline(common_util.PACK_VALUE_LIB)

vec3 packSSS(float f)
{
	f = clamp(f / 256.0, 0.0, 1.0);
	return packValue(f);
}

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	// Subsurface depth
	gl_FragData[0] = vec4(packSSS(sss), 1.0);
	
	// Channel radius
	gl_FragData[1] = vec4(uSSSRadius, 1.0);
}
