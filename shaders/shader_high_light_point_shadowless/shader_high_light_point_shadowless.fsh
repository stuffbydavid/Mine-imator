#define PI 3.14159265

uniform sampler2D uTexture;
uniform sampler2D uTextureMaterial;
uniform sampler2D uTextureNormal;
uniform vec2 uTexScale;
uniform vec2 uTexScaleMaterial;
uniform vec2 uTexScaleNormal;

uniform int uIsSky;
uniform int uLightAmount;
uniform vec4 uLightData[96];
uniform int uIsWater;
uniform int uMaterialUseGlossiness;
uniform vec3 uCameraPosition;
uniform float uMetallic;
uniform float uRoughness;
uniform float uSpecularStrength;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;

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
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec3 lightResult = vec3(0.0);
	vec3 specResult = vec3(0.0);
	
	if (uIsSky > 0)
	{
		lightResult = vec3(1.0);
		specResult = vec3(uSpecularStrength);
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
		
		for (int i = 0; i < uLightAmount; i++)
		{
			vec4 data1 = uLightData[i * 3];
			vec4 data2 = uLightData[i * 3 + 1];
			vec4 data3 = uLightData[i * 3 + 2];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w;
			float lightFadeSize = data2.w;
			
			// No use in shading a pixel if it's not in range
			if (distance(vPosition, lightPosition) > lightRange)
				continue;
			
			// Diffuse factor
			float dif = max(0.0, dot(normalize(normal), normalize(lightPosition - vPosition)));
			
			// Attenuation factor
			float att = 1.0 - clamp((distance(vPosition, lightPosition) - lightRange * (1.0 - lightFadeSize)) / (lightRange * lightFadeSize), 0.0, 1.0);
			dif *= att;
			
			vec3 light = vec3(0.0);
			vec3 spec = vec3(0.0);
			
			// Diffuse light
			light = data2.rgb * data3.r * dif;
			
			lightResult.rgb += light;
			
			// Calculate specular
			vec3 N   = normal;
			vec3 V   = normalize(uCameraPosition - vPosition);
			vec3 L   = normalize(lightPosition - vPosition);
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
			
			spec = data2.rgb * specular * mix(vec3(1.0), baseColor.rgb * vColor.rgb, metallic) * data3.g * uSpecularStrength * dif;
			specResult.rgb += spec;
		}
	}
	
	gl_FragData[0] = vec4(lightResult, baseColor.a);
	gl_FragData[1] = vec4(specResult, baseColor.a);
	
	if (baseColor.a == 0.0)
		discard;
}

