#define PI 3.14159265
#define NUM_CASCADES 3

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightDirection;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uSunNear[NUM_CASCADES];
uniform float uSunFar[NUM_CASCADES];

uniform sampler2D uDepthBuffer0;
uniform sampler2D uDepthBuffer1;
uniform sampler2D uDepthBuffer2;
uniform float uCascadeEndClipSpace[NUM_CASCADES];
uniform int uCascadeDebug;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;
uniform float uSpecularStrength;

uniform int uSpecular;
uniform vec3 uCameraPosition;
uniform float uRoughness;
uniform float uMetallic;

uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;
uniform int uMaterialUseGlossiness;

uniform sampler2D uTextureNormal;
uniform vec2 uTexScaleNormal;

varying vec3 vPosition;
varying float vDepth;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord[NUM_CASCADES];
varying float vBrightness;
varying float vBlockSSS;
varying float vClipSpaceDepth;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(1.0 - cosTheta, 5.0);
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

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

vec4 cascadeDepthBuffer(int index, vec2 coord)
{
	if (index == 0)
		return texture2D(uDepthBuffer0, coord);
	else if (index == 1)
		return texture2D(uDepthBuffer1, coord);
	else
		return texture2D(uDepthBuffer2, coord);
}

#extension GL_OES_standard_derivatives : enable
vec3 getMappedNormal(vec3 normal, vec3 viewPos, vec3 worldPos, vec2 uv)
{
	if (uIsWater == 1)
		return normal;
	
	// Get edge derivatives
	vec3 posDx = dFdx(worldPos);
	vec3 posDy = dFdy(worldPos);
	vec2 texDx = dFdx(uv);
	vec2 texDy = dFdy(uv);
	
	// Calculate tangent/bitangent
	vec3 posPx = cross(normal, posDx);
	vec3 posPy = cross(posDy, normal);
	vec3 T = normalize(posPy * texDx.x + posPx * texDy.x);
	T = normalize(T - dot(T, normal) * normal);
	vec3 B = cross(normal, T);
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	mat3 TBN = mat3(T * invmax, B * invmax, normal);
	
	// Get normal value from normal map
	vec2 normtex = uv;
	if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
		normtex = mod(normtex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
	
	vec3 normalCoord = texture2D(uTextureNormal, normtex).rgb * 2.0 - 1.0;
	
	if (normalCoord.z < 0.0)
		return normal;
	
	return normalize(TBN * normalCoord);
}

void main()
{
	vec3 light;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex) * uBlendColor.a;
	
	if (uIsSky > 0)
	{
		if (uSpecular == 0)
			light = vec3(0.0);
		else
			light = vec3(uSpecularStrength);
	}
	else
	{
		// Get material data
		vec2 texMat = vTexCoord;
		if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
			texMat = mod(texMat * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
		
		vec3 mat = texture2D(uTextureMaterial, texMat).rgb;
		float roughness = max(0.02, 1.0 - ((1.0 - uRoughness) * (uMaterialUseGlossiness == 0 ? 1.0 - mat.r : mat.r)));
		float metallic = (mat.g * uMetallic);
		float brightness = (vBrightness * mat.b);
		
		vec3 normal = getMappedNormal(normalize(vNormal), vPosition, vPosition, fract(vTexCoord));
		
		// Diffuse factor
		float dif = max(0.0, dot(normalize(normal), uLightDirection));	
		dif = clamp(dif, 0.0, 1.0);
		
		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);
		
		if ((dif > 0.0 && brightness < 1.0) || sssEnabled == 1)
		{
			// Find the cascade to use
		    int i;
		    for (i = 0; i < NUM_CASCADES; i++)
		        if (vClipSpaceDepth < uCascadeEndClipSpace[i])
		            break;
			
			float fragDepth = vScreenCoord[i].z;
			vec2 fragCoord = vScreenCoord[i].xy;
			
			// Just in case something went wrong in clipping
			if (fragCoord.x < 0.0 || fragCoord.y < 0.0 || fragDepth < 0.0 || fragCoord.x > 1.0 || fragCoord.y > 1.0 || fragDepth > 1.0)
			{
				i += 1;
				fragDepth = vScreenCoord[i].z;
				fragCoord = vScreenCoord[i].xy;
			}
			
			if (uCascadeDebug == 1)
			{
				if (i == 0)
					shadow *= vec3(1.0, 0.5, 0.5);
				else if (i == 1)
					shadow *= vec3(0.5, 1.0, 0.5);
				else if (i == 2)
					shadow *= vec3(0.5, 0.5, 1.0);
				else
					shadow *= vec3(0.0, 0.0, 0.0);
			}
			
			// Texture position must be valid
			if (fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragDepth >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0 && fragDepth <= 1.0 && i < NUM_CASCADES)
			{	
				// Convert 0->1 to Near->Far
				fragDepth = uSunNear[i] + fragDepth * (uSunFar[i] - uSunNear[i]);
				
				// Calculate bias
				float bias = 1.0;
				
				// Find shadow
				float sampleDepth = uSunNear[i] + unpackDepth(cascadeDepthBuffer(i, fragCoord)) * (uSunFar[i] - uSunNear[i]);
				shadow *= ((fragDepth - bias) > sampleDepth) ? vec3(0.0) : vec3(1.0);
				
				if (sssEnabled == 1 && uSpecular == 0)
				{
					// Get subsurface translucency
					vec3 dis = vec3(uSSSRadius * max(uSSS, vBlockSSS));
					float lightdis = (fragDepth + bias) - sampleDepth;
					
					if (dif == 0.0 && ((fragDepth + bias) > sampleDepth || vBlockSSS > 0.0))
					{
						if (vBlockSSS > 0.0 && (fragDepth - (bias * 0.01)) <= sampleDepth)
							lightdis = 0.0;
						
						subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
					}
				}
			}
		}
		
		if (uSpecular == 0)
		{
			// Translucency
			float transDif = max(0.0, dot(normalize(-normal), uLightDirection));
			transDif = clamp(transDif, 0.0, 1.0);
			subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
			
			// Calculate light
			light = uLightColor.rgb * uLightStrength * dif * shadow;
			light += subsurf;
			
			// Apply SSS color to all lighting
			light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
			
			light = mix(light, vec3(1.0), brightness);
		}
		else
		{
			vec3 N   = normal;
			vec3 L   = uLightDirection;
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
			
			light = uLightColor.rgb * specular * mix(vec3(1.0), baseColor.rgb, metallic) * shadow * uSpecularStrength * dif;
		}
	}
	
	// Set final color
	gl_FragColor = vec4(light, baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
