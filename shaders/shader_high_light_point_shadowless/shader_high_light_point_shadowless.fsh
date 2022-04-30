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
uniform float uBrightness;
uniform int uIsWater;
uniform int uMaterialUseGlossiness;
uniform int uSpecular;
uniform vec3 uCameraPosition;
uniform float uMetallic;
uniform float uRoughness;
uniform float uSpecularStrength;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vBrightness;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

// GGX specular (https://learnopengl.com/PBR/Lighting)
float distributionGGX(vec3 N, vec3 H, float roughness)
{
    float a      = roughness * roughness;
    float a2     = a * a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;
	
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return num / denom;
}

float geometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = geometrySchlickGGX(NdotV, roughness);
    float ggx1  = geometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
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
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec3 lightResult = vec3(0.0);
	
	if (uIsSky > 0)
	{
		if (uSpecular == 0)
			lightResult = vec3(1.0);
		else
			lightResult = vec3(uSpecularStrength);
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
		
		vec3 normal = getMappedNormal(normalize(vNormal), vPosition, vPosition, vTexCoord);
		
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
			
			// Calculate light
			if (uSpecular == 0)
			{
				light = data2.rgb * data3.r * dif;
				light = mix(light, vec3(1.0), brightness);
		
				lightResult.rgb += light;
			}
			else
			{
				vec3 N   = normal;
				vec3 V   = normalize(uCameraPosition - vPosition);
				vec3 L   = normalize(lightPosition - vPosition);
				vec3 H   = normalize(V + L);
				float NDF = distributionGGX(N, H, roughness);       
				float G   = geometrySmith(N, V, L, roughness);
				
				float F0, F90, F;
				F0 = mix(0.04, 1.0, metallic);
				F90 = mix(0.48, 1.0, metallic);
				
				F = fresnelSchlick(max(dot(H, V), 0.0), F0, F90);
				F = mix(F * (1.0 - pow(roughness, 8.0)), F, metallic);
				
				float numerator    = NDF * G * F;
				float denominator  = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001;
				float specular     = numerator / denominator;
				
				light = data2.rgb * specular * mix(vec3(1.0), baseColor.rgb * vColor.rgb, metallic) * att * data3.g * uSpecularStrength;
				lightResult.rgb += light;
			}
		}
	}
	
	gl_FragColor = vec4(lightResult, baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}

