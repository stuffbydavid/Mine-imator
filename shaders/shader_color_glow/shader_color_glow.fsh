uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform int uGlow;
uniform int uGlowTexture;
uniform vec4 uGlowColor;
uniform int uBlockGlow;

uniform int uFogShow;
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

uniform vec3 uCameraPosition;

varying vec3 vPosition;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vBrightness;

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
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	// Glow isn't enabled on object, but bright blocks should still glow
	if (uGlow < 1 && uBlockGlow > 0)
		baseColor.rgb *= vec3(vBrightness);
	else
	{
		if (uGlowTexture > 0)
			baseColor.rgb *= uGlowColor.rgb;
		else
			baseColor.rgb = uGlowColor.rgb;
	}
	baseColor.rgb *= vec3(1.0 - getFog());
	
	gl_FragColor = baseColor;
	
	if (gl_FragColor.a <= 0.98)
		discard;
}
