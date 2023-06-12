uniform sampler2D uTexture; // static
uniform sampler2D uTextureMaterial; // static

uniform float uSampleIndex;
uniform int uAlphaHash;

uniform int uColorsExt;
uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

uniform int uFogShow;
uniform vec4 uFogColor; // static
uniform float uFogDistance; // static
uniform float uFogSize; // static
uniform float uFogHeight; // static

uniform float uDefaultEmissive;
uniform float uDefaultSubsurface;
uniform int uMaterialFormat;
uniform float uMetallic;
uniform float uRoughness;
uniform float uEmissive;

uniform vec4 uFallbackColor;
uniform vec4 uAmbientColor;

uniform vec3 uCameraPosition; // static

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying vec4 vCustom;

vec4 rgbtohsb(vec4 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, c.a);
}

vec4 hsbtorgb(vec4 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return vec4(c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), c.a);
}

float getFog()
{
	float fog;
	if (uFogShow > 0)
	{
		float fogDepth = distance(vPosition, uCameraPosition);
		
		fog = clamp(1.0 - (uFogDistance - fogDepth) / uFogSize, 0.0, 1.0);
		fog *= clamp(1.0 - (vPosition.z - uFogHeight) / uFogSize, 0.0, 1.0);
	}
	else
		fog = 0.0;
	
	return fog;
}

// Fresnel Schlick approximation
float fresnelSchlickRoughness(float cosTheta, float F0, float roughness)
{
	return clamp(F0 + (max((1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0), 0.0, 1.0);
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

/// ACES (implementation by Stephen Hill, @self_shadow)
vec3 RRTAndODTFit(vec3 v)
{
	vec3 a = v * (v + 0.0245786) - 0.000090537;
	vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	return a / b;
}

vec3 mapACES(vec3 color)
{
	// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
	color = vec3(
		color.r * 0.59719 + color.g * 0.35458 + color.b * 0.04823,
		color.r * 0.07600 + color.g * 0.90834 + color.b * 0.01566,
		color.r * 0.02840 + color.g * 0.13383 + color.b * 0.83777
	);
	
	color = RRTAndODTFit(color);
	
	// ODT_SAT => XYZ => D60_2_D65 => sRGB
	color = vec3(
		color.r *  1.60475 + color.g * -0.53108 + color.b * -0.07367,
		color.r * -0.10208 + color.g *  1.10813 + color.b * -0.00605,
		color.r * -0.00327 + color.g * -0.07276 + color.b *  1.07602
	);
	
	return color;
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	// Fresnel
	vec3 N = vNormal;
	vec3 V = normalize(uCameraPosition - vPosition);
	vec3 H = normalize(V + -reflect(V, N));
	float F = fresnelSchlickRoughness(max(dot(H, V), 0.0), F0, roughness);
	
	// Diffuse
	vec3 dif;
	
	// Assume no shading
	if (vDiffuse.r < 0.0)
	{
		dif = vec3(1.0);
		F = 0.0;
	}
	else
		dif = vDiffuse + uAmbientColor.rgb;
	
	dif *= (1.0 - F);
	dif = max(vec3(0.0), dif);
	
	vec4 col;
	vec3 spec;
	
	if (baseColor.a == 0.0)
		discard;
	
	if (uColorsExt > 0)
	{
		col = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
		col = hsbtorgb(clamp(rgbtohsb(col) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
		col = mix(col, uMixColor, uMixColor.a); // Mix
	}
	else
		col = baseColor;
	
	if (vDiffuse.r >= 0.0)
		col.rgb = pow(col.rgb, vec3(uGamma));
	
	// Get specular color
	spec = (mix(vec3(1.0), col.rgb, metallic) * pow(uFallbackColor.rgb, vec3(uGamma)) * F);
	
	dif *= (1.0 - metallic);
	
	// Emissive
	dif += emissive;
	
	col.rgb *= dif; // Multiply diffuse
	
	col.rgb += spec;
	
	if (vDiffuse.r >= 0.0)
	{
		col.rgb *= uExposure;
		
		// Tone map
		if (uTonemapper == 1)
			col.rgb /= (1.0 + col.rgb); // Reinhard
		else if (uTonemapper == 2)
			col.rgb = mapACES(col.rgb); // ACES
		
		col.rgb = pow(col.rgb, vec3(1.0/uGamma));
	}
	
	col = mix(col, uFogColor, getFog()); // Mix fog
	col.a = mix(baseColor.a, 1.0, F); // Correct alpha
	
	if (uAlphaHash > 0)
	{
		if (col.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0))))
			discard;
		else
			col.a = 1.0;
	}
	
	gl_FragColor = col;
}
