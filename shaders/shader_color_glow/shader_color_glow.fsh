uniform sampler2D uTexture;
uniform vec2 uTexScale;

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
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

uniform vec3 uCameraPosition;

varying vec3 vPosition;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
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

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
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
	
	gl_FragColor = baseColor;
	
	if ((gl_FragColor.a <= 0.98 && uGlow < 1) || gl_FragColor.a == 0.0)
		discard;
}
