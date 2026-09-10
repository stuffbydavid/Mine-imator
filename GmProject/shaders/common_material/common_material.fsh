#pragma shady: skip_compilation
void main() {}

#region NORMAL_MAP_LIB
#pragma shady: macro_begin NORMAL_MAP_LIB

uniform sampler2D uTextureNormal; // static
uniform int uUseNormalMap; // static

vec3 getMappedNormal(vec2 uv, mat3 tbn)
{
	if (uUseNormalMap < 1)
		return vec3(tbn[2][0], tbn[2][1], tbn[2][2]);
	
	vec4 n = texture2D(uTextureNormal, uv).rgba;
	n.xy = n.xy * 2.0 - 1.0; // Decode
	n.xy = sign(n.xy) * max(abs(n.xy) - 1.0 / 255.0, 0.0) * (255.0 / 254.0); // 127/128 rg fix, 8bit tex can't represent perfect 0
	n.z = sqrt(max(0.0, 1.0 - dot(n.xy, n.xy))); // Get Z
	n.y *= -1.0; // Convert Y- to Y+
	return normalize(tbn * n.xyz);
}

#pragma shady: macro_end
#endregion

#region MATERIAL_LIB
#pragma shady: macro_begin MATERIAL_LIB

//#pragma shady: inline(common_constants.MATH)

uniform sampler2D uTextureMaterial; // static
uniform int uMaterialFormat;
uniform float uDefaultEmissive;
uniform float uDefaultSubsurface;
uniform float uRoughness;
uniform float uMetallic;
uniform float uEmissive;
uniform float uSSS;

void getMaterial(out float roughness, out float metallic, out float emissive, out float F0, out float sss)
{
	vec4 matColor = texture2D(uTextureMaterial, vTexCoord);
	float baseEmissive = max(uEmissive, vCustom.z * uDefaultEmissive);
	
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
		
		roughness = (1.0 - matColor.r);
		emissive = max(baseEmissive, (matColor.a < 1.0 ? matColor.a / 0.9961 : 0.0) * uDefaultEmissive);
		
		return;
	}
	
	if (uMaterialFormat == 1) // SEUS
	{
		roughness = (1.0 - matColor.r);
		metallic = matColor.g;
		emissive = max(baseEmissive, matColor.b * uDefaultEmissive);
	}
	else // No map
	{
		roughness = uRoughness;
		metallic = uMetallic;
		emissive = baseEmissive;
	}
	
	/* F0 = DIELECTRIC_F0; */
	F0 = 0.0; // Ignore DIELECTRIC_F0 for artistic reasons (MI/SEUS)
	sss = max(uSSS, vCustom.w * uDefaultSubsurface);
}


#pragma shady: macro_end
#endregion

#region FRESNEL_LIB
#pragma shady: macro_begin FRESNEL_LIB

// Fresnel Schlick approximation
float fresnelSchlickRoughness(float cosTheta, float F0, float roughness)
{
	return F0 + (max((1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
	return F0 + (vec3(1.0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 getDirectFresnel(vec3 N, vec3 L, vec3 camPos, vec3 pos, vec3 F0)
{
	vec3 V = normalize(camPos - pos);
	vec3 halfway = V + L;
	if (dot(N, L) <= 0.0 || dot(halfway, halfway) < 0.000001)
		return F0;
	
	vec3 H = normalize(halfway);
	return fresnelSchlick(max(dot(H, V), 0.0), F0);
}

float getFresnel(vec3 N, float f0, float roughness, vec3 camPos, vec3 pos)
{
	vec3 V  = normalize(camPos - pos);
	vec3 H  = normalize(V + -reflect(V, N));
	return fresnelSchlickRoughness(max(dot(H, V), 0.0), f0, roughness);
}

#pragma shady: macro_end
#endregion

#region ALPHA_DISCARD_LIB
#pragma shady: macro_begin ALPHA_DISCARD_LIB

uniform float uSampleIndex;
uniform int uAlphaHash;

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
}

void handleAlphaDiscard(vec3 pos, inout vec4 col)
{
	if (col.a > .99)
		col.a = 1.0;
	
	if (col.a < 0.001)
		discard;
	
	if (uAlphaHash > 0)
	{
		if (col.a < hash(vec2(hash(pos.xy + (uSampleIndex / 255.0)), pos.z + (uSampleIndex / 255.0))))
			discard;
		else
			col.a = 1.0;
	}
}

#pragma shady: macro_end
#endregion

#region SPECULAR_LIB
#pragma shady: macro_begin SPECULAR_LIB

#pragma shady: inline(common_constants.MATH)

// GGX specular (https://learnopengl.com/PBR/Lighting)
float distributionGGX(vec3 N, vec3 H, float perceptualRoughness)
{
	perceptualRoughness = clamp(perceptualRoughness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
	float alpha = perceptualRoughness * perceptualRoughness;
	float a2 = alpha * alpha;
	float NdotH = max(dot(N, H), 0.0);
	float denom = ((NdotH * NdotH) * (a2 - 1.0) + 1.0);
	return a2 / (PI * denom * denom);
}

float geometrySchlickGGX(float NdotV, float roughness)
{
	roughness = clamp(roughness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
	float r = (roughness + 1.0);
	float k = (r * r) / 8.0;
	
	return NdotV / (NdotV * (1.0 - k) + k);
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
	return	geometrySchlickGGX(abs(dot(N, V)), roughness) *
			geometrySchlickGGX(max(dot(N, L), 0.0), roughness);
}

vec3 getSpecular(vec3 N, vec3 L, vec3 camPos, vec3 pos, vec3 F0, float roughness)
{
	vec3 V = normalize(camPos - pos);
	float NdotL = dot(N, L);
	vec3 halfway = V + L;

	if (NdotL <= 0.0 || dot(halfway, halfway) < 0.000001)
		return vec3(0.0);

	float NdotV = abs(dot(N, V)) + 0.00001;
	vec3 H = normalize(halfway);
	
	float NDF = distributionGGX(N, H, roughness);
	float G = geometrySmith(N, V, L, roughness);
	vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);
	
	vec3 numerator = NDF * G * F;
	float denominator = 4.0 * NdotV * NdotL + 0.0001;
	return numerator / denominator;
}

#pragma shady: macro_end
#endregion

#region SSS_TRANSLUCENCY_LIB
#pragma shady: macro_begin SSS_TRANSLUCENCY_LIB

uniform vec4 uSSSColor;
uniform float uSSSHighlight;
uniform float uSSSHighlightStrength;

float CSPhase(float dotView, float scatter)
{
	float result = (3.0 * (1.0 - (scatter * scatter))) * (1.0 + dotView);
	result /= 2.0 * (2.0 + pow(scatter, 2.0)) * pow(1.0 + pow(scatter, 2.0) - 2.0 * scatter * dotView, 1.5);
	return result;
}

vec3 getSubsurfaceTranslucency(float fragDepth, float sampleDepth, float bias, vec3 lightCol, vec3 rad)
{
	vec3 dis = vec3((fragDepth + bias) - sampleDepth) / (lightCol * rad);
	
	if ((fragDepth - (bias * 0.01)) <= sampleDepth)
		dis = vec3(0.0);
	
	return pow(max(1.0 - pow(dis / rad, vec3(4.0)), 0.0), vec3(2.0)) / (pow(dis, vec3(2.0)) + 1.0);			
}

void handleSubsurfaceHighlight(inout vec3 light, inout vec3 subsurf, vec3 N, vec3 lightDir, vec3 lightCol, vec3 camPos, vec3 pos, float sss, float mask)
{
	float transDif = max(0.0, dot(normalize(-N), lightDir));
	subsurf += (subsurf * uSSSHighlightStrength * CSPhase(dot(normalize(pos - camPos), lightDir), uSSSHighlight));
	light += lightCol * uSSSColor.rgb * transDif * subsurf * mask;
	light *= mix(vec3(1.0), uSSSColor.rgb, clamp(sss, 0.0, 1.0));
}

#pragma shady: macro_end
#endregion

#region SAMPLE_GGX_LIB
#pragma shady: macro_begin SAMPLE_GGX_LIB

vec3 sampleGGX(vec2 Xi, float roughness)
{
	roughness = clamp(roughness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
	float a = roughness * roughness;
	float phi = TWO_PI * Xi.x;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	
	return vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
}

// Sample a GGX reflection normal optimized for the camera view (VNDF)
// https://jcgt.org/published/0007/04/01/
vec3 sampleGGXVNDF(vec2 Xi, vec3 viewDir, float roughness)
{
	roughness = clamp(roughness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
	float a = roughness * roughness;
	
	// Reshape the view so roughness is easier to sample evenly
	vec3 viewH = normalize(vec3(a * viewDir.xy, max(viewDir.z, 0.0001)));
	float lensq = dot(viewH.xy, viewH.xy);
	vec3 tangent1 = (lensq > 0.0 ? vec3(-viewH.y, viewH.x, 0.0) / sqrt(lensq) : vec3(1.0, 0.0, 0.0));
	vec3 tangent2 = cross(viewH, tangent1);

	// Pick a random point
	float r = sqrt(Xi.x);
	float phi = TWO_PI * Xi.y;
	float t1 = r * cos(phi);
	float t2 = r * sin(phi);
	float s = 0.5 * (1.0 + viewH.z);
	t2 = mix(sqrt(max(0.0, 1.0 - t1 * t1)), t2, s);
	vec3 normalH = tangent1 * t1 + tangent2 * t2 + viewH * sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2));

	// Undo reshape to get normal
	return normalize(vec3(a * normalH.xy, max(normalH.z, 0.0)));
}

#pragma shady: macro_end
#endregion
