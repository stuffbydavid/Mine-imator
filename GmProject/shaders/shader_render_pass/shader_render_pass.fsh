uniform int uChannel;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	
	if (uChannel == 1)
		color.rgb = vec3(color.r);
	else if (uChannel == 2)
		color.rgb = vec3(color.g);
	else if (uChannel == 3)
		color.rgb = vec3(color.b);
	else if (uChannel == 4)
		color.rgb = vec3(color.a);
	
	gl_FragColor = vec4(color.rgb * vColor.rgb, 1.0);
}
