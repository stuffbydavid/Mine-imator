#define PI 3.14159265

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uLightNear;
uniform float uLightFar;
uniform float uLightFadeSize;
uniform float uLightSpotSharpness;
uniform vec3 uShadowPosition;
uniform float uSpecularStrength;

uniform sampler2D uDepthBuffer;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;

uniform vec3 uCameraPosition;
uniform float uRoughness;
uniform float uMetallic;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying float vBlockSSS;

uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;
uniform int uMaterialUseGlossiness;

uniform sampler2D uTextureNormal;
uniform vec2 uTexScaleNormal;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

// GGX specular (https://learnopengl.com/PBR/Lighting)
float distributionGGX(vec3 N, vec3 H, float roughness)
{
    float a2      = roughness * roughness * roughness * roughness;
    float NdotH  = max(dot(N, H), 0.0);
    float denom = (NdotH * NdotH * (a2 - 1.0) + 1.0);
    return a2 / (PI * denom * denom);
}

float geometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
	
	return NdotV / (NdotV * (1.0 - k) + k);
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    return	geometrySchlickGGX(max(dot(N, V), 0.0), roughness) *
			geometrySchlickGGX(max(dot(N, L), 0.0), roughness);
}

vec3 getMappedNormal(vec2 uv)
{
	vec3 texColor = normalize(texture2D(uTextureNormal, uv).rgb * 2.0 - 1.0);
	
	if ((texColor.r + texColor.g + texColor.b) < 0.001)
		return vNormal;
	
	mat3 TBN = mat3(vTangent, cross(vTangent, vNormal), vNormal);
	return normalize(TBN * texColor);
}

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

void main() 
{
	vec3 light, spec;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	
	if (uIsSky > 0)
	{
		light = vec3(0.0);
		spec = vec3(uSpecularStrength);
	}
	else
	{
		// Get material data
		vec2 texMat = vTexCoord;
		if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
			texMat = mod(texMat * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
		
		vec2 normalTex = vTexCoord;
		if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
			normalTex = mod(normalTex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
		
		vec3 mat = texture2D(uTextureMaterial, texMat).rgb;
		float roughness = max(0.02, 1.0 - ((1.0 - uRoughness) * (uMaterialUseGlossiness == 0 ? 1.0 - mat.r : mat.r)));
		float metallic = (mat.g * uMetallic);
		
		vec3 normal = getMappedNormal(normalTex);
		
		float dif = 0.0;
		float difMask = 0.0;
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Check if not behind the spot light
		if (vScreenCoord.w > 0.0)
		{
			// Diffuse factor
			dif = max(0.0, dot(normalize(normal), normalize(uLightPosition - vPosition)));
			
			// Attenuation factor
			att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0);
			dif *= att;
			
			if (dif > 0.0 || sssEnabled == 1)
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
				fragDepth = min(vShadowCoord.z, uLightFar);
				fragCoord = (vec2(vShadowCoord.x, -vShadowCoord.y) / vShadowCoord.z + 1.0) * 0.5;
				
				if (difMask > 0.0)
				{
					// Calculate bias
					float bias = 1.0;
					
					// Shadow
					float sampleDepth = uLightNear + unpackDepth(texture2D(uDepthBuffer, fragCoord)) * (uLightFar - uLightNear);
					shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
					
					if (sssEnabled == 1)
					{
						// Get subsurface translucency
						vec3 dis = vec3(uSSSRadius * max(uSSS, vBlockSSS));
						float lightdis = (fragDepth + bias) - sampleDepth;
						
						if (dif == 0.0 && ((fragDepth + bias) > sampleDepth || vBlockSSS > 0.0))
						{
							if (vBlockSSS > 0.0 && (fragDepth - (bias * 0.01)) <= sampleDepth)
								lightdis = 0.0;
							
							subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
							subsurf *= att;
						}
					}
				}
			}
		}
		
		// Diffuse light
		light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		// Subsurface translucency
		float transDif = max(0.0, dot(normalize(-normal), normalize(uLightPosition - vPosition)));
		transDif = clamp(transDif, 0.0, 1.0);
		subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
		light += subsurf * difMask;
		light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
		
		// Calculate specular
		vec3 N   = normal;
		vec3 L   = normalize(uLightPosition - vPosition);
		vec3 V   = normalize(uCameraPosition - vPosition);
		vec3 H   = normalize(V + L);
		float NDF = distributionGGX(N, H, roughness);       
		float G   = geometrySmith(N, V, L, roughness);
		
		float F0, F90, F;
		F0 = mix(mix(0.04, 0.0, roughness), 1.0, metallic);
		F90 = mix(mix(0.7, 0.0, roughness), 1.0, metallic);
		F = fresnelSchlick(max(dot(H, V), 0.0), F0, F90);
		
		float numerator    = NDF * G * F;
		float denominator  = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001;
		float specular     = numerator / denominator;
		
		spec = uLightColor.rgb * shadow * difMask * uSpecularStrength * dif * (specular * mix(vec3(1.0), baseColor.rgb * uBlendColor.rgb, metallic));
	}
	
	gl_FragData[0] = vec4(light, uBlendColor.a * baseColor.a);
	gl_FragData[1] = vec4(spec, uBlendColor.a * baseColor.a);
	
	if (uBlendColor.a * baseColor.a == 0.0)
		discard;
}
