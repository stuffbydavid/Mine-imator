uniform sampler2D uTexture;
uniform vec2 uTexScale;

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

uniform vec3 uCameraPosition;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vDepth;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec3 vDiffuse;

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
float fresnelSchlick(float cosTheta, float F0)
{
	return F0 + (1.0 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	// Material
	vec3 dif = (vDiffuse * (1.0 - uMetallic));
	float F0 = 0.04;
	F0 = mix(F0, 0.0, uMetallic);
	
	vec3 V = normalize(vPosition - uCameraPosition);
	vec3 L = -normalize(reflect(V, normalize(vNormal)));
	vec3 H = V + L;
	float fresnel = fresnelSchlick(max(dot(H, V), 0.0), F0);
	fresnel *= 1.0 - pow(uRoughness, 8.0);
	
	if (baseColor.a == 0.0)
		discard;
	
	if (uColorsExt > 0)
	{
		gl_FragColor = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
		gl_FragColor = hsbtorgb(clamp(rgbtohsb(gl_FragColor) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
		gl_FragColor = mix(gl_FragColor, uMixColor, uMixColor.a); // Mix
		
		gl_FragColor *= vec4(dif, 1.0); // Multiply diffuse
		gl_FragColor = mix(gl_FragColor, uFallbackColor, fresnel);
		
		gl_FragColor = mix(gl_FragColor, uFogColor, getFog()); // Mix fog
		gl_FragColor.a = mix(baseColor.a, 1.0, fresnel); // Correct alpha
	}
	else
	{
		gl_FragColor = baseColor * vec4(dif, 1.0); // Multiply diffuse
		gl_FragColor = mix(gl_FragColor, uFallbackColor, fresnel);
		
		gl_FragColor = mix(gl_FragColor, uFogColor, getFog()); // Mix fog
		gl_FragColor.a = mix(baseColor.a, 1.0, fresnel); // Correct alpha
	}
}
