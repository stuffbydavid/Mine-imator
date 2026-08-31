uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform sampler2D uGlintTexture; // static
uniform vec2 uGlintOffset;
uniform vec2 uGlintSize;
uniform int uGlintEnabled;
uniform float uGlintStrength;

uniform float uGamma;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uGlintEnabled > 0 && baseColor.a > 0.0)
		baseColor.rgb = pow(texture2D(uGlintTexture, (tex * ((uTextureSize / uGlintSize))) + uGlintOffset).rgb * baseColor.a * uGlintStrength, vec3(uGamma));
	else
		baseColor.rgb = vec3(0.0);
	
	gl_FragColor = baseColor;
}
