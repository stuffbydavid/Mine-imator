#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin GBUFFERS_LIB

uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;
uniform vec3 uCameraPosition; // static
uniform float uGamma;
uniform int uIsSky;
uniform float uSSAO;
uniform int uGlintPass; // static

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

void getGbuffers(
	out vec4 baseColor, out vec3 normalWorld,
	out float roughness, out float metallic,
	out float F0, out float sss,
	out vec4 depth, out vec4 normal, out vec4 material, out vec4 glint
)
{
	vec2 tex = vTexCoord;
	baseColor = vColor * texture2D(uTexture, tex);

	handleAlphaDiscard(vPosition, baseColor);

	// Material
	float emissive;
	getMaterial(roughness, metallic, emissive, F0, sss);

	vec3 normalView;
	if (uHasNormalMap < 1 && uIsWater == 0)
	{
		normalWorld = normalize(vNormalWorld);
		normalView = normalize(vNormalView);
	}
	else
	{
		mat3 tbnWorld = getTBN(vNormalWorld, vTangentWorld);
		mat3 tbnView = getTBN(vNormalView, vTangentView);
		normalWorld = getMaterialNormal(tex, vPosition, tbnWorld);
		normalView = transformMaterialNormal(normalWorld, tbnWorld, tbnView);
	}

	float F = getFresnel(normalWorld, mix(F0, 1.0, metallic), roughness, uCameraPosition, vPosition);
	if (uIsSky > 0)
		F = 0.0;

	depth = vec4(vDepth, 0.0, 0.0, 1.0);
	normal = vec4(packNormal(normalView).rgb, emissive);
	material = vec4(roughness, metallic, F, uSSAO);

	if (uGlintPass > 0)
		glint = vec4(getGlint(baseColor, tex, uTextureSize, uGamma), 1.0);
	else
		glint = vec4(0.0);
}

#pragma shady: macro_end
