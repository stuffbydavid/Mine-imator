uniform float uThreshold;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	if (max(max(baseColor.r, baseColor.g), baseColor.b) > uThreshold)
		gl_FragColor = baseColor;
	else
		gl_FragColor = vec4(vec3(0.0), 1.0);
}