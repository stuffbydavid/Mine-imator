uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform sampler2D uGlintTexture; // static
uniform vec2 uGlintOffset;
uniform vec2 uGlintSize;
uniform int uGlintEnabled;
uniform float uGlintStrength;

uniform float uGamma;

uniform float uSampleIndex;
uniform int uAlphaHash;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	if (baseColor.a < 0.0001)
		discard;
	
	if (uAlphaHash > 0)
	{
		if (baseColor.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0))))
			discard;
		else
			baseColor.a = 1.0;
	}
	
	if (uGlintEnabled > 0 && baseColor.a > 0.0)
		baseColor.rgb = pow(texture2D(uGlintTexture, (tex * ((uTextureSize / uGlintSize))) + uGlintOffset).rgb * baseColor.a * uGlintStrength, vec3(uGamma));
	else
		baseColor.rgb = vec3(0.0);
	
	gl_FragColor = baseColor;
}
