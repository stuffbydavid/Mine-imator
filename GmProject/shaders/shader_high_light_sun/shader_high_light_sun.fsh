#define PI 3.14159265
#define NUM_CASCADES 3

uniform sampler2D uTexture; // static
uniform int uIsSky;
uniform int uIsWater;

uniform float uSampleIndex;
uniform int uAlphaHash;

uniform vec3 uLightDirection; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uSunNear[NUM_CASCADES]; // static
uniform float uSunFar[NUM_CASCADES]; // static

uniform sampler2D uDepthBuffer0; // static
uniform sampler2D uDepthBuffer1; // static
uniform sampler2D uDepthBuffer2; // static
uniform float uCascadeEndClipSpace[NUM_CASCADES]; // static

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;
uniform float uSSSHighlight;
uniform float uSSSHighlightStrength;
uniform float uLightSpecular;

uniform float uDefaultSubsurface;
uniform float uDefaultEmissive;
uniform int uMaterialFormat;

uniform vec3 uCameraPosition; // static
uniform float uRoughness;
uniform float uMetallic;
uniform float uEmissive;

uniform sampler2D uTextureMaterial; // static
uniform sampler2D uTextureNormal; // static

varying vec3 vPosition;
varying float vDepth;
varying vec3 vNormal;
varying vec3 vTangent;
varying mat3 vTBN;
varying vec2 vTexCoord;
varying vec4 vScreenCoord[NUM_CASCADES];
varying vec4 vCustom;
varying float vClipSpaceDepth;
varying vec4 vColor;

// Fresnel Schlick approximation
float fresnelSchlickRoughness(float cosTheta, float F0, float roughness)
{
	return F0 + (max((1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

// GGX specular (https://learnopengl.com/PBR/Lighting)
float distributionGGX(vec3 N, vec3 H, float roughness)
{
	float a2 = roughness * roughness * roughness * roughness;
	float NdotH = max(dot(N, H), 0.0);
	float denom = ((NdotH * NdotH) * (a2 - 1.0) + 1.0);
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

vec3 getMappedNormal(vec2 uv)
{
	vec4 n = texture2D(uTextureNormal, uv).rgba;
	n.rgba = (n.a < 0.01 ? vec4(.5, .5, 0.0, 1.0) : n.rgba); // No normal?
	n.xy = n.xy * 2.0 - 1.0; // Decode
	n.z = sqrt(max(0.001, 1.0 - dot(n.xy, n.xy))); // Get Z
	n.y *= -1.0; // Convert Y- to Y+
	return normalize(vTBN * n.xyz);
}

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
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
			sss = (matColor.b > 0.255 ? (((matColor.b - 0.255) / 0.745) * max(uSSS, uDefaultSubsurface)) : 0.0);
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
	sss = max(uSSS, vCustom.w * uDefaultSubsurface);
}

float CSPhase(float dotView, float scatter)
{
	float result = (3.0 * (1.0 - (scatter * scatter))) * (1.0 + dotView);
	result /= 2.0 * (2.0 + pow(scatter, 2.0)) * pow(1.0 + pow(scatter, 2.0) - 2.0 * scatter * dotView, 1.5);
	return result;
}

void main()
{
	vec3 light, spec;
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	
	if (uAlphaHash > 0)
	{
		if (baseColor.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0))))
			discard;
		else
			baseColor.a = 1.0;
	}
	
	if (uIsSky > 0)
	{
		light = vec3(0.0);
		spec = vec3(uLightSpecular);
	}
	else
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		
		vec3 normal = getMappedNormal(vTexCoord);
		
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
			
			float fragDepth = vScreenCoord[i].z;
			vec2 fragCoord = vScreenCoord[i].xy;
			
			// Texture position must be valid
			if (fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0)
			{	
				// Convert 0->1 to Near->Far
				fragDepth = uSunNear[i] + fragDepth * (uSunFar[i] - uSunNear[i]);
				
				// Calculate bias
				float bias = 1.0 + (float(i) * 2.0);
				
				// Find shadow
				float sampleDepth = uSunNear[i] + unpackDepth(cascadeDepthBuffer(i, fragCoord)) * (uSunFar[i] - uSunNear[i]);
				shadow *= ((fragDepth - bias) > sampleDepth) ? vec3(0.0) : vec3(1.0);
				
				// Get subsurface translucency
				if (sss > 0.0 && dif == 0.0)
				{
					vec3 rad = uSSSRadius * sss;
					vec3 dis = vec3((fragDepth + bias) - sampleDepth) / (uLightColor.rgb * uLightStrength * rad);
					
					if ((fragDepth - (bias * 0.01)) <= sampleDepth)
						dis = vec3(0.0);
					
					subsurf = pow(max(1.0 - pow(dis / rad, vec3(4.0)), 0.0), vec3(2.0)) / (pow(dis, vec3(2.0)) + 1.0);
				}
			}
		}
		
		// Diffuse light
		light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		// Subsurface translucency
		if (sss > 0.0)
		{
			float transDif = max(0.0, dot(normalize(-normal), uLightDirection));
			subsurf += (subsurf * uSSSHighlightStrength * CSPhase(dot(normalize(vPosition - uCameraPosition), uLightDirection), uSSSHighlight));
			light += uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif * subsurf;
			light *= mix(vec3(1.0), uSSSColor.rgb, clamp(sss, 0.0, 1.0));
		}
		
		// Calculate specular
		if (uLightSpecular * dif * shadow.r > 0.0)
		{
			vec3 N = normal;
			vec3 L = uLightDirection;
			vec3 V = normalize(uCameraPosition - vPosition);
			vec3 R = reflect(V, N);
			
			vec3 H = normalize(V + L);
			float NDF = distributionGGX(N, H, roughness);
			float G = geometrySmith(N, V, L, roughness);
			
			float F = fresnelSchlickRoughness(max(dot(H, V), 0.0), F0, roughness);
			
			float numerator = NDF * G * F;
			float denominator  = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001;
			float specular = numerator / denominator;
			
			spec = uLightColor.rgb * uLightSpecular * dif * shadow * (specular * mix(vec3(1.0), baseColor.rgb, metallic));
		}
		else
			spec = vec3(0.0);
	}
	
	// Set final color
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
	
	if (baseColor.a == 0.0)
		discard;
}
