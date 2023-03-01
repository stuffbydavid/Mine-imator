varying vec2 vTexCoord;

uniform float uDistortAmount;
uniform int uRepeatImage;
uniform float uZoomAmount;

vec2 distort(vec2 coord, float amount)
{
	float d = dot(coord, coord);
	float distortion = amount * -0.25;
	coord *= 1.0 + distortion * d + distortion * d * d;
	return coord;
}

void main()
{
	// Transform UV to -1 -> 1
	vec2 uv = (vTexCoord - 0.5) * 2.0;
	uv /= uZoomAmount;
	
	uv = distort(uv, uDistortAmount);
	uv = (uv * 0.5) + 0.5;
	
	vec4 color = texture2D(gm_BaseTexture, uv);
	
	if (uRepeatImage < 1)
	{
		if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
			color = vec4(0.0);
	}
	
	gl_FragColor = vec4(color);
}
