uniform sampler2D uTexture; // static
uniform int uIsSky;

uniform vec3 uLightPosition; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uLightNear; // static
uniform float uLightFar; // static
uniform float uLightFadeSize; // static
uniform int uLightRealisticFalloff;
uniform float uLightSpotSharpness; // static
uniform float uShadowRadius; // static
uniform vec3 uShadowPosition; // static
uniform float uLightSpecular;
uniform float uLightSize;

uniform mat4 uShadowMatrix; // static
uniform sampler2D uDepthBuffer; // static
uniform float uDepthBufferSize; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static

uniform vec3 uSSSRadius;

uniform vec3 uCameraPosition; // static
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying vec4 vCustom;
varying vec4 vColor;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_pcss.PCSS_COMMON_LIB)
#pragma shady: inline(common_shadows.PCSS_PLANE_LIB)

float getSpotDepth(vec2 coord)
{
	return uLightNear + texture2D(uDepthBuffer, coord).r * (uLightFar - uLightNear);
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

	vec2 coord;
	vec2 depthSlope;
};

float getShadowMapDepth(ShadowReceiver receiver, vec2 texelCoord)
{
	return getSpotDepth(texelCoord);
}

#pragma shady: inline(common_pcss.PCSS_PROJECTED_LIB)
#pragma shady: inline(common_pcss.PCSS_FILTER_LIB)

float getSpotShadow(vec2 coord, float fragDepth, vec2 depthSlope, float bias, out float centerDepth)
{
	centerDepth = getSpotDepth(coord);
	if (uShadowBlurQuality <= 0 || uShadowRadius <= 0.0)
		return getPCSSVisibility(fragDepth, centerDepth, bias);

	ShadowReceiver receiver;
	receiver.depth = fragDepth;
	receiver.bias = bias;
	// Cover the full blur range
	receiver.searchRadius = 64.0 / PCSS_REFERENCE_SHADOW_SIZE;
	// Start the blocker search within half a texel
	float localRadius = min(uShadowRadius / max(fragDepth, uLightNear), 0.5 / uDepthBufferSize);
	receiver.localRadius = min(localRadius, receiver.searchRadius);
	receiver.lightRadius = uShadowRadius;
	receiver.radiusScale = 1.0 / max(fragDepth, uLightNear);
	receiver.nearDepth = uLightNear;
	receiver.perspective = true;
	receiver.coord = coord;
	receiver.depthSlope = depthSlope;

	return getPCSSShadow(receiver, uShadowBlurQuality);
}

void main() 
{
	vec3 light = vec3(0.0);
	vec3 spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	float shadowFragDepth = min(vShadowCoord.z, uLightFar);
	vec2 shadowFragCoord = (vec2(vShadowCoord.x, -vShadowCoord.y) / max(vShadowCoord.z, 0.0001) + 1.0) * 0.5;
	vec2 depthSlope = getPCSSSpotSlope(uShadowMatrix, vShadowCoord.xyz, normalize(vNormal));
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMaterialNormal(vTexCoord, vPosition, getTBN(vNormal, vTangent));
		vec3 lightDir = normalize(uLightPosition - vPosition);
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, lightDir, uCameraPosition, vPosition, specularF0);
		
		float dif = 0.0;
		float difMask = 0.0;
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Check if not behind the spot light
		if (vScreenCoord.w > 0.0)
		{
			// Diffuse factor
			dif = max(0.0, dot(normal, lightDir));
			
			// Attenuation factor
			att = getLightAttenuation(distance(vPosition, uLightPosition), uLightFar, uLightFadeSize, uLightRealisticFalloff);
			dif *= att;
			
			if (dif > 0.0 || sss > 0.0)
			{
				// Spotlight circle
				float fragDepth = min(vScreenCoord.z, uLightFar);
				vec2 fragCoord = (vec2(vScreenCoord.x, -vScreenCoord.y) / vScreenCoord.z + 1.0) * 0.5;
				
				// Texture position must be valid
				if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0)
				{
					// Create circle
					difMask = 1.0 - clamp((distance(fragCoord, vec2(0.5, 0.5)) - 0.5 * uLightSpotSharpness) / (0.5 * max(0.01, 1.0 - uLightSpotSharpness)), 0.0, 1.0);
				} 
				else
					difMask = 0.0;
				
				dif *= difMask;
				
				// Calculate shadow
				fragDepth = shadowFragDepth;
				fragCoord = shadowFragCoord;
				
				if (difMask > 0.0)
				{
					// Calculate bias
					float bias = 1.0;
					
					// Shadow
					float sampleDepth;
					shadow = getSpotShadow(fragCoord, fragDepth, depthSlope, bias, sampleDepth);
					
					// Subsurface translucency
					if (sss > 0.0 && dif == 0.0)
						subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, uSSSRadius * sss) * att;
				}
			}
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, difMask);
		
		light *= (vec3(1.0) - F) * (1.0 - metallic);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow > 0.0)
		{
			float sphereNormalization;
			vec3 sphereLightDir = getSphereLightDirection(normal, uCameraPosition, vPosition, uLightPosition - vPosition, uLightSize * 0.5, roughness, sphereNormalization);
			vec3 specular = getSpecular(normal, sphereLightDir, uCameraPosition, vPosition, specularF0, roughness) * sphereNormalization;
			float specularStrength = uLightSpecular * (uLightRealisticFalloff > 0 ? uLightStrength : 1.0);
			spec = uLightColor.rgb * shadow * specularStrength * dif * specular;
		}
	}
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
