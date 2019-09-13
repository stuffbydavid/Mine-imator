varying vec2 vTexCoord;

uniform float uBlurAmount;
uniform vec3 uColorOffset;
uniform int uDistortChannels;

vec2 distort(vec2 coord, float amount)
{
	float d = dot(coord, coord);
	float distortion = amount * -0.25;
	coord *= 1.0 + distortion * d + distortion * d * d;
	return coord;
}

vec3 getColor(vec2 coord, vec3 offset)
{
	int quality = 32;
	vec3 color = vec3(0.0);
	vec3 offsetStart = offset;
	
	for (int i = 0; i < quality; i++)
	{
		vec2 uv = (coord - 0.5) * 2.0;
		
		// Distort or scale RGB channels?
		vec2 uvRed, uvGreen, uvBlue;
		
		if (uDistortChannels > 0)
		{
			uvRed = distort(uv, offset.x);
			uvGreen = distort(uv, offset.y);
			uvBlue = distort(uv, offset.z);
		}
		else
		{
			uvRed = uv * (1.0 - offset.x * .25);
			uvGreen = uv * (1.0 - offset.y * .25);
			uvBlue = uv * (1.0 - offset.z * .25);
		}
		
		// Transform UV to 0 -> 1
		uvRed = (uvRed * 0.5) + 0.5;
		uvGreen = (uvGreen * 0.5) + 0.5;
		uvBlue = (uvBlue * 0.5) + 0.5;
		
		color.r += texture2D(gm_BaseTexture, uvRed).r;
		color.g += texture2D(gm_BaseTexture, uvGreen).g;
		color.b += texture2D(gm_BaseTexture, uvBlue).b;
		offset = mix(offsetStart, offsetStart + uBlurAmount, float(i) / float(quality));
	}
	
	return color / float(quality);
}

void main()
{
	vec3 color = getColor(vTexCoord, uColorOffset);
	float alpha = texture2D(gm_BaseTexture, vTexCoord).a;
	
	gl_FragColor = vec4(color, alpha);
}
