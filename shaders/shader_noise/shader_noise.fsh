varying vec2 vTexCoord;

uniform sampler2D uNoiseBuffer;

uniform float uTime;
uniform float uStrength;
uniform float uSaturation;
uniform vec2 uSize;

uniform vec2 uScreenSize;

vec4 hsbtorgb(vec4 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return vec4(c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), c.a);
}

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	vec2 coords = vTexCoord * (uScreenSize / uSize);
	
	vec4 noisecolor = texture2D(uNoiseBuffer, coords);
	
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(noisecolor.rgb, W));
	noisecolor.rgb = mix(satIntensity, noisecolor.rgb, uSaturation);
		
	baseColor.rgb += vec3(noisecolor.rgb) * uStrength;
	
	gl_FragColor = vec4(baseColor);
}