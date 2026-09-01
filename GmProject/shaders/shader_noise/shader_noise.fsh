varying vec2 vTexCoord;

uniform sampler2D uNoiseBuffer;

uniform float uTime;
uniform float uStrength;
uniform float uSaturation;
uniform vec2 uSize;

uniform vec2 uScreenSize;

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
