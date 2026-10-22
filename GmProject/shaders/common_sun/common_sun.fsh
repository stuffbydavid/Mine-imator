#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin SUN_LIB

#define NUM_CASCADES 3

uniform vec3 uLightDirection; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uSunNear[NUM_CASCADES]; // static
uniform float uSunFar[NUM_CASCADES]; // static
uniform float uCascadeWorldSize[NUM_CASCADES]; // static

uniform sampler2D uDepthBuffer0; // static pass_uv depth_uv
uniform sampler2D uDepthBuffer1; // static pass_uv depth_uv
uniform sampler2D uDepthBuffer2; // static pass_uv depth_uv
uniform float uCascadeEndClipSpace[NUM_CASCADES]; // static
uniform int uCascadeCount; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static
uniform float uSunShadowDistance; // static
uniform float uSunShadowScale; // static
uniform float uDepthBufferSize; // static

uniform vec3 uSSSRadius;
uniform float uLightSpecular;
uniform float uSunAngularRadius;

varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying vec2 vDepthSlope0;
varying vec2 vDepthSlope1;
varying vec2 vDepthSlope2;
varying float vClipSpaceDepth;

#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_pcss.PCSS_COMMON_LIB)

float cascadeDepthBuffer(int index, vec2 coord)
{
	if (index == 0)
		return texture2D(uDepthBuffer0, coord).r;
	else if (index == 1)
		return texture2D(uDepthBuffer1, coord).r;
	else
		return texture2D(uDepthBuffer2, coord).r;
}

float getSunDepth(int cascade, vec2 coord, float range)
{
	return uSunNear[cascade] + cascadeDepthBuffer(cascade, coord) * range;
}

struct ShadowReceiver
{
	float depth;
	float bias;
	float localRadius;
	float searchRadius;
	float lightRadius;
	float radiusScale;
	float nearDepth;
	bool perspective;

	int cascade;
	vec2 coord;
	vec2 depthSlope;
	float depthRange;
};

float getShadowMapDepth(ShadowReceiver receiver, vec2 texelCoord)
{
	return getSunDepth(receiver.cascade, texelCoord, receiver.depthRange);
}

#pragma shady: inline(common_pcss.PCSS_PROJECTED_LIB)
#pragma shady: inline(common_pcss.PCSS_FILTER_LIB)

float getSunShadow(
	int cascade, vec2 coord, float fragDepth, float depthRange,
	vec2 depthSlope, float bias,
	out float centerDepth
)
{
	// Match the unblurred lookup to the texels used by the blur filter
	vec2 centerCoord = getShadowTexelCoord(coord, vec2(uDepthBufferSize), vec2(0.0), vec2(1.0));
	centerDepth = getSunDepth(cascade, centerCoord, depthRange);
	float surfaceDepth = getPCSSReceiverDepth(coord, fragDepth, centerCoord, depthSlope);
	if (uShadowBlurQuality <= 0 || uSunShadowScale <= 0.000001)
		return getPCSSVisibility(surfaceDepth, centerDepth, bias);

	float inverseWorldSize = 1.0 / max(uCascadeWorldSize[cascade], 0.0001);
	// Scale the minimum blur footprint consistently across cascades
	float blurSize = uSunShadowScale / max(uSunAngularRadius, 0.000001);
	float filterWorldSize = uCascadeWorldSize[0];
	if (uCascadeCount == 1)
		filterWorldSize *= min(1.0, max(300.0, uSunShadowDistance * 0.1) / max(uSunShadowDistance, 0.0001));
	float minimumRadius = blurSize * filterWorldSize / PCSS_REFERENCE_SHADOW_SIZE * inverseWorldSize;

	ShadowReceiver receiver;
	receiver.depth = fragDepth;
	receiver.bias = bias;
	receiver.searchRadius = max(uSunShadowScale * uSunShadowDistance * inverseWorldSize, minimumRadius);
	receiver.localRadius = min(receiver.searchRadius, max(minimumRadius, 0.5 / uDepthBufferSize));
	receiver.lightRadius = uSunShadowScale;
	receiver.radiusScale = inverseWorldSize;
	receiver.nearDepth = 0.0;
	receiver.perspective = false;
	receiver.cascade = cascade;
	receiver.coord = coord;
	receiver.depthSlope = depthSlope;
	receiver.depthRange = depthRange;

	return getPCSSShadow(receiver, uShadowBlurQuality, minimumRadius, centerDepth, surfaceDepth);
}

void getSunLighting(
	vec4 baseColor, vec3 normal,
	float roughness, float metallic,
	float F0, float sss,
	out vec3 light, out vec3 spec
)
{
	light = vec3(0.0);
	spec = vec3(0.0);
	
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	if (uIsSky == 0)
	{
		vec3 subsurfaceRadius = uSSSRadius * sss;
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, uLightDirection, uCameraPosition, vPosition, specularF0);

		// Diffuse factor
		float dif = clamp(max(0.0, dot(normal, uLightDirection)), 0.0, 1.0);

		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);

		if (dif > 0.0 || sss > 0.0)
		{
			// Find the cascade to use
			int i;
			for (i = 0; i < uCascadeCount; i++)
				if (vClipSpaceDepth < uCascadeEndClipSpace[i])
					break;
			bool cascadeValid = i < uCascadeCount;
			if (i >= uCascadeCount)
				i = uCascadeCount - 1;

			vec4 screenCoord;
			vec2 depthSlope;
			float bias;
			if (i == 0)
			{
				screenCoord = vScreenCoord0;
				depthSlope = vDepthSlope0;
				bias = 1.0;
			}
			else if (i == 1)
			{
				screenCoord = vScreenCoord1;
				depthSlope = vDepthSlope1;
				bias = 3.0;
			}
			else
			{
				i = 2;
				screenCoord = vScreenCoord2;
				depthSlope = vDepthSlope2;
				bias = 6.0;
			}

			float fragDepth = screenCoord.z;
			vec2 fragCoord = screenCoord.xy;

			// Texture position must be valid
			if (cascadeValid && fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0)
			{
				// Convert 0->1 to Near->Far
				float depthRange = uSunFar[i] - uSunNear[i];
				fragDepth = uSunNear[i] + fragDepth * depthRange;
				depthSlope *= depthRange;

				// Find shadow
				float sampleDepth;
				shadow *= vec3(getSunShadow(i, fragCoord, fragDepth, depthRange, depthSlope, bias, sampleDepth));

				// Subsurface translucency
				if (sss > 0.0 && dif == 0.0)
					subsurf += getSubsurfaceTranslucency(fragDepth, sampleDepth, subsurfaceRadius);
			}
		}

		// Diffuse light
		light = lightCol * dif * shadow;

		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, uLightDirection, lightCol, uCameraPosition, vPosition, sss, 1.0);

		light *= (vec3(1.0) - F) * (1.0 - metallic);

		// Calculate specular
		if (uLightSpecular * dif * shadow.r > 0.0)
		{
			float diskNormalization;
			vec3 diskLightDir = getSphereLightDirection(normal, uCameraPosition, vPosition, uLightDirection, uSunAngularRadius, roughness, diskNormalization);
			vec3 specular = getSpecular(normal, diskLightDir, uCameraPosition, vPosition, specularF0, roughness) * diskNormalization;
			spec = lightCol * uLightSpecular * dif * shadow * specular;
		}
	}
}
#pragma shady: macro_end
