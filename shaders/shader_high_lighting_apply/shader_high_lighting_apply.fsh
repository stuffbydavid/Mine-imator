#define PI 3.14159265359

uniform int uSSAOEnabled;
uniform sampler2D uSSAO;

uniform int uShadowsEnabled;
uniform sampler2D uShadows;
uniform sampler2D uSpecular;

uniform sampler2D uIndirect;
uniform int uIndirectEnabled;
uniform float uIndirectStrength;

uniform sampler2D uMask;
uniform sampler2D uMaterialBuffer;
uniform int uReflectionsEnabled;
uniform vec4 uFallbackColor;

uniform vec4 uAmbientColor;

uniform int uGammaCorrect;

varying vec2 vTexCoord;

void main()
{
	float gamma = (uGammaCorrect > 0 ? 2.2 : 1.0);
	
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	// Apply gamma to base
	baseColor.rgb = pow(baseColor.rgb, vec3(gamma));
	
	vec4 matColor = texture2D(uMaterialBuffer, vTexCoord); // R = metallic, B = fresnel
	vec3 spec = mix(vec3(1.0), baseColor.rgb, matColor.r) * pow(uFallbackColor.rgb, vec3(gamma)) * matColor.b;
	
	// Sum up lighting
	vec3 diffuse = vec3(1.0);
	
	if (uShadowsEnabled > 0)
	{
		diffuse = texture2D(uShadows, vTexCoord).rgb + pow(uAmbientColor.rgb, vec3(gamma));
		
		// Calculate indirect
		if (uIndirectEnabled > 0)
			diffuse += texture2D(uIndirect, vTexCoord).rgb * uIndirectStrength;
	}
	
	// Reduce diffuse based on Metallic
	baseColor.rgb *= (1.0 - matColor.r);
	
	// "Energy conservation", remove diffuse based on fresnel
	diffuse *= (1.0 - matColor.b);
	
	baseColor.rgb *= mix(vec3(1.0), diffuse, texture2D(uMask, vTexCoord).rgb);
	
	// Apply AO
	if (uSSAOEnabled > 0)
		baseColor.rgb *= texture2D(uSSAO, vTexCoord).rgb;
	
	// If reflections are disabled, add fallback color for fresnel
	if (uReflectionsEnabled == 0)
		baseColor.rgb += spec;
	
	if (uShadowsEnabled > 0)
		baseColor.rgb += texture2D(uSpecular, vTexCoord).rgb;
	
	baseColor.rgb = pow(baseColor.rgb, vec3(1.0/gamma));
	
	gl_FragColor = baseColor;
}
