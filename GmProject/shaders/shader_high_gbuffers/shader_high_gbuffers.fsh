uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;
uniform vec3 uCameraPosition; // static
uniform float uGamma;
uniform int uIsSky;
uniform float uSSAO;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec4 vColor;
varying vec3 vNormalView;
varying vec3 vTangentView;
varying vec3 vNormalWorld;
varying vec3 vTangentWorld;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_effect.EFFECT_GLINT_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	// Material
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);

	float F = getFresnel(getMappedNormal(tex, getTBN(vNormalWorld, vTangentWorld)), F0, roughness, uCameraPosition, vPosition);
	if (uIsSky > 0)
		F = 0.0;

	gl_FragData[0] = vec4(vDepth, 0.0, 0.0, 1.0); // Depth
	gl_FragData[1] = vec4(packNormal(getMappedNormal(tex, getTBN(vNormalView, vTangentView))).rgb, emissive); // Normal, emissive
	gl_FragData[2] = vec4(roughness, metallic, F, uSSAO); // Material, SSAO
	gl_FragData[3] = vec4(getGlint(baseColor, tex, uTextureSize, uGamma), 1.0); // Glint
}
