uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;
uniform int uMaterialUseGlossiness;

uniform int uColorsExt;
uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

uniform int uFogShow;
uniform vec4 uFogColor;
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

uniform float uMetallic;
uniform float uRoughness;
uniform vec4 uFallbackColor;
uniform vec4 uAmbientColor;

uniform vec3 uCameraPosition;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;
varying float vBrightness;

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
float fresnelSchlick(float cosTheta, float F0, float F90)
{
	return F0 + (F90 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec2 texMat = vTexCoord;
	if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
		texMat = mod(texMat * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
	vec4 matColor = texture2D(uTextureMaterial, texMat);
	
	// Flip roughness
	if (uMaterialUseGlossiness == 0)
		matColor.r = 1.0 - matColor.r;
	
	float metallic, roughness, brightness;
	metallic = (uMetallic * matColor.g); // Metallic
	roughness = 1.0 - ((1.0 - uRoughness) * matColor.r); // Roughness
	brightness = (vBrightness * matColor.b); // Brightness
	
	metallic = clamp(metallic, 0.0, 1.0);
	roughness = clamp(roughness, 0.0, 1.0);
	brightness = clamp(brightness, 0.0, 1.0);
	
	// Diffuse
	vec3 dif;
	
	// Assume no shading
	if (vDiffuse.r < 0.0)
		dif = vec3(1.0);
	else
		dif = mix(vDiffuse, vec3(1.0), brightness) + uAmbientColor.rgb;
	
	// Fresnel
	float F0, F90;
	F0 = mix(mix(0.24, .04, roughness), 1.0, metallic);
	F90 = mix(mix(0.7, .48, roughness), 1.0, metallic);
	
	// Material
	vec3 N = normalize(vNormal);
	vec3 V = normalize(vPosition - uCameraPosition);
	vec3 L = -normalize(reflect(V, N));
	vec3 H = V + L;
	float F = fresnelSchlick(max(dot(H, V), 0.0), F0, F90);
	F = mix(F * (1.0 - pow(roughness, 8.0)), F, metallic);
	
	F = clamp(F, 0.0, 1.0);
	
	dif *= (1.0 - F);
	
	vec4 col;
	vec3 spec;
	
	if (baseColor.a == 0.0)
		discard;
	
	if (uColorsExt > 0)
	{
		col = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
		col = hsbtorgb(clamp(rgbtohsb(col) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
		col = mix(col, uMixColor, uMixColor.a); // Mix
		
		// Get specular color
		spec = (mix(vec3(1.0), col.rgb, metallic) * uFallbackColor.rgb * F);
		
		col.rgb *= (1.0 - metallic);
		col.rgb *= dif; // Multiply diffuse
		
		col.rgb  = clamp(col.rgb, vec3(0.0), vec3(1.0));
		col.rgb += spec;
		
		col   = mix(col, uFogColor, getFog()); // Mix fog
		col.a = mix(baseColor.a, 1.0, F); // Correct alpha
	}
	else
	{
		col = baseColor;
		
		// Get specular color
		spec = (mix(vec3(1.0), col.rgb, metallic) * uFallbackColor.rgb * F);
		
		col.rgb *= (1.0 - metallic);
		col.rgb *= dif; // Multiply diffuse
		
		col.rgb  = clamp(col.rgb, vec3(0.0), vec3(1.0));
		col.rgb += spec;
		
		col   = mix(col, uFogColor, getFog()); // Mix fog
		col.a = mix(baseColor.a, 1.0, F); // Correct alpha
	}
	
	gl_FragColor = col;
}
