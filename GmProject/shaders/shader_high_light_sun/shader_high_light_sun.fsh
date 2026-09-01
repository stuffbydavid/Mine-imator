#define PI 3.14159265
#define NUM_CASCADES 3

uniform sampler2D uTexture; // static
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightDirection; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uSunNear[NUM_CASCADES]; // static
uniform float uSunFar[NUM_CASCADES]; // static

uniform sampler2D uDepthBuffer0; // static
uniform sampler2D uDepthBuffer1; // static
uniform sampler2D uDepthBuffer2; // static
uniform float uCascadeEndClipSpace[NUM_CASCADES]; // static

uniform vec3 uSSSRadius;
uniform float uLightSpecular;

uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying vec4 vCustom;
varying float vClipSpaceDepth;
varying vec4 vColor;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_util.UNPACK_VALUE_LIB)

vec4 cascadeDepthBuffer(int index, vec2 coord)
{
	if (index == 0)
		return texture2D(uDepthBuffer0, coord);
	else if (index == 1)
		return texture2D(uDepthBuffer1, coord);
	else
		return texture2D(uDepthBuffer2, coord);
}

void main()
{
	vec3 light, spec;
	light = vec3(0.0);
	spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		
		vec3 normal = getMappedNormal(vTexCoord, getTBN(vNormal, vTangent));
		vec3 subsurfaceRadius = uSSSRadius * sss;
		
		// Diffuse factor
		float dif = clamp(max(0.0, dot(normal, uLightDirection)), 0.0, 1.0);	
		
		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);
		
		if (dif > 0.0 || sss > 0.0)
		{
			// Find the cascade to use
			int i;
			for (i = 0; i < NUM_CASCADES; i++)
				if (vClipSpaceDepth < uCascadeEndClipSpace[i])
					break;
			
			vec4 screenCoord;
			if (i == 0)
				screenCoord = vScreenCoord0;
			else if (i == 1)
				screenCoord = vScreenCoord1;
			else
			{
				i = 2;
				screenCoord = vScreenCoord2;
			}
			
			float fragDepth = screenCoord.z;
			vec2 fragCoord = screenCoord.xy;
			
			// Texture position must be valid
			if (fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0)
			{	
				// Convert 0->1 to Near->Far
				fragDepth = uSunNear[i] + fragDepth * (uSunFar[i] - uSunNear[i]);
				
				// Calculate bias
				float bias = 1.0 + (float(i) * 2.0);
				
				// Find shadow
				float sampleDepth = uSunNear[i] + unpackValue(cascadeDepthBuffer(i, fragCoord)) * (uSunFar[i] - uSunNear[i]);
				shadow *= ((fragDepth - bias) > sampleDepth) ? vec3(0.0) : vec3(1.0);
				
				// Subsurface translucency
				if (sss > 0.0 && dif == 0.0)
					subsurf += getSubsurfaceTranslucency(fragDepth, sampleDepth, bias, lightCol, uSSSRadius * sss);
			}
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, uLightDirection, lightCol, uCameraPosition, vPosition, sss, 1.0);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow.r > 0.0)
		{
			float specular = getSpecular(normal, uLightDirection, uCameraPosition, vPosition, F0, roughness, metallic);
			spec = uLightColor.rgb * uLightSpecular * dif * shadow * (specular * mix(vec3(1.0), baseColor.rgb, metallic));
		}
	}
	
	// Set final color
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
