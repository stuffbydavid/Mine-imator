#define PI 3.14159265359

uniform int uShadowsEnabled;
uniform int uSpecularEnabled;
uniform sampler2D uShadows;
uniform sampler2D uEmissive;
uniform sampler2D uSpecular;

uniform sampler2D uMask;
uniform sampler2D uMaterialBuffer;
uniform int uReflectionsEnabled;
uniform vec4 uFallbackColor;

uniform float uGamma;

varying vec2 vTexCoord;

float unpackEmissive(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	float mask = texture2D(uMask, vTexCoord).r;
	
	// Apply gamma to base
	baseColor.rgb = pow(baseColor.rgb, mix(vec3(1.0), vec3(uGamma), mask));
	
	vec4 matColor = texture2D(uMaterialBuffer, vTexCoord); // G = metallic, B = fresnel
	vec3 spec = mix(vec3(1.0), baseColor.rgb, matColor.g) * pow(uFallbackColor.rgb, vec3(uGamma)) * matColor.b;
	
	// Sum up lighting
	vec3 diffuse = vec3(1.0);
	
	if (uShadowsEnabled > 0)
		diffuse = texture2D(uShadows, vTexCoord).rgb;
	
	// Reduce diffuse based on Metallic
	diffuse *= (1.0 - matColor.g);
	
	// "Energy conservation", remove diffuse based on fresnel
	diffuse *= (1.0 - matColor.b);
	
	// Add emissive
	if (uShadowsEnabled > 0)
		diffuse += unpackEmissive(texture2D(uEmissive, vTexCoord) * 255.0);
	
	baseColor.rgb *= mix(vec3(1.0), diffuse, mask);
	
	// If reflections are disabled, add fallback color for fresnel
	if (uReflectionsEnabled == 0)
		baseColor.rgb += spec;
	
	if (uSpecularEnabled > 0)
		baseColor.rgb += texture2D(uSpecular, vTexCoord).rgb;
	
	gl_FragColor = baseColor;
}
