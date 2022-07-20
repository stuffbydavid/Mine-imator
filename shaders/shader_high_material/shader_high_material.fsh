uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;
uniform int uMaterialUseGlossiness;

uniform sampler2D uTextureNormal;
uniform vec2 uTexScaleNormal;

uniform vec3 uCameraPosition;
uniform float uMetallic;
uniform float uRoughness;
uniform float uEmissive;
uniform int uIsWater;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

varying float vTime;
varying float vWindDirection;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

vec3 getMappedNormal(vec2 uv)
{
	vec3 texColor = normalize(texture2D(uTextureNormal, uv).rgb * 2.0 - 1.0);
	
	if ((texColor.r + texColor.g + texColor.b) < 0.001)
		return vNormal;
	
	mat3 TBN = mat3(vTangent, cross(vTangent, vNormal), vNormal);
	return normalize(TBN * texColor);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	if (baseColor.a < 0.0001)
		discard;
	
	vec2 texMat = vTexCoord;
	if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
		texMat = mod(texMat * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
	
	vec2 normalTex = vTexCoord;
	if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
		normalTex = mod(normalTex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
	
	vec4 matColor = texture2D(uTextureMaterial, texMat);
	
	// Flip roughness
	if (uMaterialUseGlossiness == 0)
		matColor.r = 1.0 - matColor.r;
	
	// Transform values
	float metallic, roughness;
	metallic = (uMetallic * matColor.g); // Metallic
	roughness = 1.0 - ((1.0 - uRoughness) * matColor.r); // Roughness
	
	// Fresnel
	float F0, F90;
	F0 = mix(mix(0.04, 0.0, roughness), 1.0, metallic);
	F90 = mix(mix(0.7, 0.0, roughness), 1.0, metallic);
	
	vec3 N = getMappedNormal(normalTex);
	vec3 V = normalize(vPosition - uCameraPosition);
	vec3 L = -normalize(reflect(V, N));
	vec3 H = V + L;
	float F = fresnelSchlick(max(dot(H, V), 0.0), F0, F90);
	
	gl_FragData[0] = vec4(metallic, roughness, F, 1.0);
	
	// Emissive
	float em = max(0.0, baseColor.a * ((uEmissive + vCustom.z) * matColor.b));
	gl_FragData[1] = vec4(em, em, em, baseColor.a <= 0.9801 ? 0.0 : 1.0);
}
