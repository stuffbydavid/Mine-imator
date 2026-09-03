uniform sampler2D uTexture; // static

uniform vec3 uSSSRadius;
uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	gl_FragData[0] = vec4(vec3(getFog(vPosition, uCameraPosition)), 1.0); // Fog
	gl_FragData[1] = vec4(clamp(sss, 0.0, 256.0), 0.0, 0.0, 1.0); // SSS
	gl_FragData[2] = vec4(uSSSRadius, 1.0); // SSS RGB Channel Radius
}
