uniform float uThreshold;
uniform float uTransition;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	float brightness = dot(max(baseColor.rgb, vec3(0.0)), vec3(0.2126, 0.7152, 0.0722));
	float transition = max(uTransition, 0.0);
	float contribution = transition > 0.0 ? smoothstep(uThreshold - transition, uThreshold + transition, brightness) : step(uThreshold, brightness);
	gl_FragColor = vec4(baseColor.rgb * contribution, 1.0);
}