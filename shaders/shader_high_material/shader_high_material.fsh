uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform sampler2D uMaterialTexture;
uniform vec2 uMaterialTexScale;
uniform int uMaterialUseGlossiness;

uniform sampler2D uNormalTexture;
uniform vec2 uNormalTexScale;

uniform vec3 uCameraPosition;
uniform float uMetallic;
uniform float uRoughness;
uniform int uIsWater;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;

varying float vTime;
varying float vWindDirection;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

#extension GL_OES_standard_derivatives : enable
vec3 getMappedNormal(vec3 normal, vec3 viewPos, vec3 worldPos, vec2 uv)
{
	// Get normal map UV
	vec2 texCoord = uv;
	vec3 texColor = vec3(0.0);
	
	// Displace water normal map
	if (uIsWater > 0)
	{
		vec2 angle = vec2(cos(vWindDirection), sin(vWindDirection)) * .125 * vTime;
		texCoord = (worldPos.xy + angle) / 128.0;
	}
	
	// Fix UV coordinate
	if (uNormalTexScale.x < 1.0 || uNormalTexScale.y < 1.0)
		texCoord = mod(texCoord * uNormalTexScale, uNormalTexScale); // GM sprite bug workaround
	
	texColor = texture2D(uNormalTexture, texCoord).rgb * 2.0 - 1.0;
	
	// Reduce water normal map strength
	if (uIsWater > 0)
		texColor = mix(texColor, vec3(0.0, 0.0, 1.0), 0.9);
	
	// No normal present in map, skip
	if (texColor.z < 0.0)
		return normal;
	
	// Get edge derivatives
	vec3 posDx = dFdx(worldPos);
	vec3 posDy = dFdy(worldPos);
	vec2 texDx = dFdx(uv);
	vec2 texDy = dFdy(uv);
	
	// Calculate tangent/bitangent
	vec3 posPx = cross(normal, posDx);
	vec3 posPy = cross(posDy, normal);
	vec3 T = posPy * texDx.x + posPx * texDy.x;
	vec3 B = posPy * texDx.y + posPx * texDy.y;
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	mat3 TBN = mat3(T * invmax, B * invmax, normal);
	
	return normalize(TBN * texColor);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec2 matTex = vTexCoord;
	if (uMaterialTexScale.x < 1.0 || uMaterialTexScale.y < 1.0)
		matTex = mod(matTex * uMaterialTexScale, uMaterialTexScale); // GM sprite bug workaround
	
	vec2 normalTex = vTexCoord;
	if (uNormalTexScale.x < 1.0 || uNormalTexScale.y < 1.0)
		normalTex = mod(normalTex * uNormalTexScale, uNormalTexScale); // GM sprite bug workaround
	
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	vec4 matColor = texture2D(uMaterialTexture, matTex);
	
	// Flip roughness
	if (uMaterialUseGlossiness == 0)
		matColor.r = 1.0 - matColor.r;
	
	// Transform values
	float metallic, roughness;
	metallic = (uMetallic * matColor.g); // Metallic
	roughness = 1.0 - ((1.0 - uRoughness) * matColor.r); // Roughness
	
	// Fresnel
	float F0, F90;
	F0 = mix(0.04, 1.0, metallic);
	F90 = mix(0.48, 1.0, metallic);
	
	vec3 N = getMappedNormal(normalize(vNormal), vPosition, vPosition, vTexCoord);
	vec3 V = normalize(vPosition - uCameraPosition);
	vec3 L = -normalize(reflect(V, N));
	vec3 H = V + L;
	float F = fresnelSchlick(max(dot(H, V), 0.0), F0, F90);
	F = mix(F * (1.0 - pow(roughness, 8.0)), F, metallic);
	
	if (baseColor.a > 0.0)
		gl_FragColor = vec4(metallic, roughness, F, 1.0);
	else
		discard;
}
