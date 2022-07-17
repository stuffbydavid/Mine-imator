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
vec3 getMappedNormal(vec3 N, vec3 pos, vec2 uv)
{
	// Get edge derivatives
	vec3 posDx = dFdx(pos);
	vec3 posDy = dFdy(pos);
	vec2 uvDx = dFdx(uv);
	vec2 uvDy = dFdy(uv);
	
	// Calculate tangent/bitangent
	vec3 posPx = cross(N, posDx);
	vec3 posPy = cross(posDy, N);
	vec3 T = normalize(posPy * uvDx.x + posPx * uvDy.x);
	T = normalize(T - dot(T, N) * N);
	vec3 B = cross(N, T);
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	mat3 TBN = mat3(T * invmax, B * invmax, N);
	
	vec3 texColor = normalize(texture2D(uTextureNormal, uv).rgb * 2.0 - 1.0);
	return normalize(TBN * texColor);
}

void main()
{
	vec3 light, spec;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex) * uBlendColor.a;
	
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
		
		vec3 normal = getMappedNormal(vNormal, vPosition, normalTex);
		
		// Diffuse factor
		float dif = max(0.0, dot(normalize(normal), uLightDirection));	
		dif = clamp(dif, 0.0, 1.0);
		
		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);
		
		if (dif > 0.0 || sssEnabled == 1)
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
					}
				}
			}
		}
		
		// Diffuse light
		light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		// Subsurface translucency
		float transDif = max(0.0, dot(normalize(-normal), uLightDirection));
		transDif = clamp(transDif, 0.0, 1.0);
		subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
		light += subsurf;
		light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
		
		// Calculate specular
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
		
		spec = uLightColor.rgb * uSpecularStrength * dif * shadow * (specular * mix(vec3(1.0), baseColor.rgb, metallic));
	}
	
	// Set final color
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
	
	if (baseColor.a == 0.0)
		discard;
}
