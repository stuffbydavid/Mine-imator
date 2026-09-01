uniform sampler2D uTexture; // static

uniform int uColorsExt;
uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

uniform int uGlow;
uniform int uGlowTexture;
uniform vec4 uGlowColor;

uniform int uFogShow;
uniform float uFogDistance; // static
uniform float uFogSize; // static
uniform float uFogHeight; // static

uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vEmissive;

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

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

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	// Glow using base texture and color settings
	if (uGlowTexture > 0)
	{
		if (uColorsExt > 0)
		{
			float baseAlpha = baseColor.a;
			baseColor = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
			baseColor = hsbtorgb(clamp(rgbtohsb(baseColor) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
			baseColor = mix(baseColor, uMixColor, uMixColor.a); // Mix
			baseColor.a = baseAlpha; // Correct alpha
		}
		
		baseColor.rgb *= uGlowColor.rgb;
	}
	else
		baseColor.rgb = uGlowColor.rgb;
	
	baseColor.rgb *= vec3(1.0 - getFog());
	
	if ((baseColor.a <= 0.98 && uGlow < 1) || baseColor.a == 0.0)
		discard;
	
	gl_FragColor = baseColor;
}
