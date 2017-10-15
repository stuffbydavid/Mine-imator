uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform int uFogShow;
uniform vec4 uFogColor;
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vDepth;

float getFog()
{
	float fog;
	if (uFogShow > 0)
	{
		fog = clamp(1.0 - (uFogDistance - vDepth) / uFogSize, 0.0, 1.0);
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
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	if (baseColor.a > 0.0)
		gl_FragColor = vec4(vec3(getFog()), 1.0);
	else
		discard;
}
