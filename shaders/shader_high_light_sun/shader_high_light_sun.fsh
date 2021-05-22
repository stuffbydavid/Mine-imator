uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition;
uniform vec3 uLightDirection;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uSunNear;
uniform float uSunFar;

uniform sampler2D uDepthBuffer;

uniform int uColoredShadows;
uniform sampler2D uColorBuffer;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;
uniform float uMetallic;

varying vec3 vPosition;
varying float vDepth;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying float vBrightness;
varying float vBlockSSS;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

void main()
{
	vec3 light;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	
	if (uIsSky > 0)
		light = vec3(1.0);
	else
	{
		// Diffuse factor
		float dif = max(0.0, dot(normalize(vNormal), uLightDirection));	
		dif = clamp(dif, 0.0, 1.0);
		
		// Material
		dif *= 1.0 - uMetallic;
		
		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);
		
		if ((dif > 0.0 && vBrightness < 1.0) || sssEnabled > 0)
		{
			float fragDepth = vScreenCoord.z * .5 + .5;
			vec2 fragCoord = vec2(vScreenCoord.x, -vScreenCoord.y) * .5 + .5;
		
			// Texture position must be valid
			if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragDepth > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0 && fragDepth < 1.0)
			{	
				// Calculate bias
				float bias = 1.0 / abs(uSunFar - uSunNear);
				
				// Colored shadows
				if (uColoredShadows > 0)
					if (baseColor.a * uBlendColor.a == 1.0)
						shadow = texture2D(uColorBuffer, fragCoord).rgb;
				
				// Find shadow
				float sampleDepth = unpackDepth(texture2D(uDepthBuffer, fragCoord));
				shadow *= ((fragDepth - bias) > sampleDepth) ? vec3(0.0) : vec3(1.0);
				
				// Get subsurface translucency
				vec3 dis = vec3((uSSSRadius * (max(uSSS, vBlockSSS) + 11.0)) / abs(uSunFar - uSunNear));
				float lightdis = (fragDepth + (bias * 10.0)) - sampleDepth;
				
				subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
			}
		}
		
		// Translucency
		float transDif = max(0.0, dot(normalize(-vNormal), uLightDirection));
		transDif = clamp(transDif, 0.0, 1.0);
		subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
		
		// Disable translucency on diffuse
		subsurf *= (dif > 0.0 ? 0.0 : 1.0);
		
		// Calculate light
		if (uIsWater == 1)
			light = uLightColor.rgb * uLightStrength * dif;
		else
			light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		light += subsurf;
		
		// Apply SSS color to all lighting
		light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
		
		light = mix(light, vec3(1.0), vBrightness);
	}
	
	// Set final color
	gl_FragColor = vec4(light, uBlendColor.a * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
