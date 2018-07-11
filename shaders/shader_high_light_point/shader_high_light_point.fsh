#define SQRT05 0.707106781
#define PI 3.14159265
#define TAU PI * 2.0
#define MAXSAMPLES 64

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;

uniform vec3 uLightPosition;
uniform vec4 uLightColor;
uniform float uLightNear;
uniform float uLightFar;
uniform float uLightFadeSize;

uniform sampler2D uDepthBufferXp;
uniform sampler2D uDepthBufferXn;
uniform sampler2D uDepthBufferYp;
uniform sampler2D uDepthBufferYn;
uniform sampler2D uDepthBufferZp;
uniform sampler2D uDepthBufferZn;

uniform int uBlurQuality;
uniform float uBlurSize;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying float vBrightness;
varying float vLightBleed;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

vec4 texture2Dmap(int map, vec2 tex)
{
	if (map == 0) return texture2D(uDepthBufferXp, tex);
	else if (map == 1) return texture2D(uDepthBufferXn, tex);
	else if (map == 2) return texture2D(uDepthBufferYp, tex);
	else if (map == 3) return texture2D(uDepthBufferYn, tex);
	else if (map == 4) return texture2D(uDepthBufferZp, tex);
	else return texture2D(uDepthBufferZn, tex);
}

vec2 getShadowMapCoord(vec3 look)
{
	float tFOV = tan(PI / 4.0);
	vec3 u, v, toPoint = vPosition - uLightPosition;
	vec2 coord;
	
	// Prepare 3D to 2D conversion
	look /= sqrt(dot(look, look));
	u = vec3(-look.z * look.x, -look.z * look.y, 1.0 - look.z * look.z);
	u /= sqrt(dot(u, u));
	u *= tFOV; 
	v = vec3(u.y * look.z - look.y * u.z, u.z * look.x - look.z * u.x, u.x * look.y - look.x * u.y);
	
	// Convert
	toPoint /= dot(toPoint,look);
	coord.x = (dot(toPoint, v) / (tFOV * tFOV) + 1.0) / 2.0;
	coord.y = (1.0 - dot(toPoint, u) / (tFOV * tFOV)) / 2.0;
	
	return coord;
}

void main()
{
	vec3 light;
	
	if (uIsSky > 0)
		light = vec3(1.0);
	else
	{
		float shadow = 0.0;
	
		// Diffuse factor
		float dif = max(0.0, dot(normalize(vNormal), normalize(uLightPosition - vPosition))); 
		dif = clamp(dif + vLightBleed, 0.0, 1.0);
		
		// Attenuation factor
		dif *= 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0); 
	 
		if (dif > 0.0 && vBrightness < 1.0)
		{
			int buffer;
			vec2 fragCoord;
			vec3 toLight = vPosition - uLightPosition;
			vec4 lookDir = vec4( // Get the direction from the pixel to the light
				toLight.x / distance(vPosition.xy, uLightPosition.xy),
				toLight.y / distance(vPosition.xy, uLightPosition.xy),
				toLight.z / distance(vPosition.xz, uLightPosition.xz),
				toLight.z / distance(vPosition.yz, uLightPosition.yz)
			);
		
			// Get shadow map and texture coordinate
		
			// Z+
			if (lookDir.z > SQRT05 && lookDir.w > SQRT05)
			{ 
				buffer = 4;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, 1.0));
			}
		
			// Z-
			else if (lookDir.z < -SQRT05 && lookDir.w < -SQRT05)
			{
				buffer = 5;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, -1.0));
			}
		
			// X+
			else if (lookDir.x > SQRT05)
			{ 
				buffer = 0;
				fragCoord = getShadowMapCoord(vec3(1.0, 0.0, 0.0));
			}
		
			// X-
			else if (lookDir.x < -SQRT05)
			{
				buffer = 1;
				fragCoord = getShadowMapCoord(vec3(-1.0, 0.0, 0.0));
			}
		
			// Y+
			else if (lookDir.y > SQRT05)
			{ 
				buffer = 2;
				fragCoord = getShadowMapCoord(vec3(0.0, 1.0, 0.0));
			}
		
			// Y-
			else
			{ 
				buffer = 3;
				fragCoord = getShadowMapCoord(vec3(0.0, -1.0, 0.0));
			}
			
			// Blur size(Increase if there's light bleeding)
			float blurSize = uBlurSize + (.2 * vLightBleed);
			
			// Calculate shadow
			float fragDepth = distance(vPosition, uLightPosition);
			float sampleSize = blurSize / fragDepth;
			float bias =  1.0 + 2.0 * blurSize;
		
			for (int i = 0; i < MAXSAMPLES; i++)
			{
				if (i < uBlurQuality)
				{
					// Sample from circle
					float angle = (float(i) / float(uBlurQuality)) * TAU;
					vec2 off = vec2(cos(angle), sin(angle));
				
					// Get sample coordinate and depth
					vec2 sampleCoord = fragCoord + off * sampleSize;
					float sampleDepth = uLightNear + (uLightFar - uLightNear) * unpackDepth(texture2Dmap(buffer, sampleCoord));
				
					// Add to shadow
					shadow += ((fragDepth - bias) > sampleDepth) ? 1.0 : 0.0;
				}
				else
					break;
			}
		
			shadow /= float(uBlurQuality);
		}
	
		// Calculate light
		light = uLightColor.rgb * dif * (1.0 - shadow);
		light = mix(light, vec3(1.0), vBrightness);
	}
	
	// Set final color
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	gl_FragColor = vec4(light, uBlendColor.a * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
