uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform vec4 uBlendColor;
uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vBlockSSS;

vec3 packSSS(float f)
{
	f = clamp(f / 256.0, 0.0, 1.0);
	return vec3(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0));
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	if (floor(baseColor.a * 255.0) < 254.0)
		discard;
	
	// Subsurface depth
	gl_FragData[0] = vec4(packSSS(max(vBlockSSS, uSSS)), 1.0);
	
	// Channel radius
	gl_FragData[1] = vec4(uSSSRadius, 1.0);
	
	// Subsurface color
	gl_FragData[2] = uSSSColor;
}