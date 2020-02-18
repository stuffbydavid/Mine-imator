uniform sampler2D uShadowExp;
uniform sampler2D uShadowDec;

uniform float uShadowsStrength;

varying vec2 vTexCoord;
varying vec4 vColor;

vec2 packShadow(float f)
{
	return vec2(floor(f / 255.0) / 255.0, fract(f / 255.0));
}

float unpackShadow(float expo, float dec)
{
	return (expo * 255.0 * 255.0) + (dec * 255.0);
}

void main()
{
	vec3 shadowExp = texture2D(uShadowExp, vTexCoord).rgb;
	vec3 shadowDec = texture2D(uShadowDec, vTexCoord).rgb;
	
	vec3 light = vec3(0.0);
	
	light.r = (unpackShadow(shadowExp.r, shadowDec.r) * uShadowsStrength) / (255.0 * 255.0);
	light.g = (unpackShadow(shadowExp.g, shadowDec.g) * uShadowsStrength) / (255.0 * 255.0);
	light.b = (unpackShadow(shadowExp.b, shadowDec.b) * uShadowsStrength) / (255.0 * 255.0);
	
	gl_FragColor = vec4(light, 1.0);
}