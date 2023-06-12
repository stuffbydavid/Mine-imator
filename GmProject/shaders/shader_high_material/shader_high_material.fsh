uniform sampler2D uTexture; // static
uniform sampler2D uTextureMaterial; // static
uniform sampler2D uTextureNormal; // static

uniform float uSampleIndex;
uniform int uAlphaHash;

uniform vec3 uCameraPosition; // static
uniform float uMetallic;
uniform float uRoughness;
uniform float uEmissive;
uniform int uIsSky;

// Materials
uniform int uMaterialFormat;
uniform float uDefaultEmissive;
uniform float uDefaultSubsurface;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;
varying mat3 vTBN;

// Fresnel Schlick approximation
float fresnelSchlickRoughness(float cosTheta, float F0, float roughness)
{
	return F0 + (max((1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 getMappedNormal(vec2 uv)
{
	vec4 n = texture2D(uTextureNormal, uv).rgba;
	n.rgba = (n.a < 0.01 ? vec4(.5, .5, 0.0, 1.0) : n.rgba); // No normal?
	n.xy = n.xy * 2.0 - 1.0; // Decode
	n.z = sqrt(1.0 - dot(n.xy, n.xy)); // Get Z
	n.y *= -1.0; // Convert Y- to Y+
	return normalize(vTBN * n.xyz);
}

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
}

vec3 packEmissive(float f)
{
	return vec3(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0));
}

void getMaterial(out float roughness, out float metallic, out float emissive, out float F0, out float sss)
{
	vec4 matColor = texture2D(uTextureMaterial, vTexCoord);
	
	if (uMaterialFormat == 2) // LabPBR
	{
		if (matColor.g > 0.898) // Metallic
		{
			metallic = 1.0; F0 = 1.0; sss = 0.0;
		}
		else // Non-metallic
		{
			metallic = 0.0; F0 = matColor.g;
			sss = (matColor.b > 0.255 ? (((matColor.b - 0.255) / 0.745) * uDefaultSubsurface) : 0.0);
		}
		
		roughness = pow(1.0 - matColor.r, 2.0);
		emissive = (matColor.a < 1.0 ? matColor.a /= 0.9961 : 0.0) * uDefaultEmissive;
		
		return;
	}
	
	if (uMaterialFormat == 1) // SEUS
	{
		roughness = (1.0 - matColor.r);
		metallic = matColor.g;
		emissive = (matColor.b * uDefaultEmissive);
	}
	else // No map
	{
		roughness = uRoughness;
		metallic = uMetallic;
		emissive = max(uEmissive, vCustom.z * uDefaultEmissive);
	}
	
	F0 = mix(0.0, 1.0, metallic);
	sss = vCustom.w * uDefaultSubsurface;
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	if (baseColor.a < 0.0001)
		discard;
	
	if (uAlphaHash > 0)
	{
		if (baseColor.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0))))
			discard;
		else
			baseColor.a = 1.0;
	}
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	// Fresnel
	vec3 N = getMappedNormal(vTexCoord);
	vec3 V  = normalize(uCameraPosition - vPosition);
	vec3 H  = normalize(V + -reflect(V, N));
	float F = fresnelSchlickRoughness(max(dot(H, V), 0.0), F0, roughness);
	
	if (uIsSky > 0)
		F = 0.0;
	
	gl_FragData[0] = vec4(roughness, metallic, F, 1.0);
	
	// Emissive
	gl_FragData[1] = vec4(packEmissive((emissive / 255.0) * baseColor.a), baseColor.a);
}
