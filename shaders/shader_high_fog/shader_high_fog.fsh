uniform sampler2D uTexture;
uniform float uAlpha;

uniform float uFogShow;
uniform vec4 uFogColor;
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;

float getFog()
{
	float fog;
	if (uFogShow > 0.0)
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
	vec4 baseColor = texture2D(uTexture, vTexCoord);
	float alpha = uAlpha * baseColor.a;
	
	if (alpha > 0.0)
		gl_FragColor = vec4(vec3(getFog()), 1.0);
	else
		discard;
}
