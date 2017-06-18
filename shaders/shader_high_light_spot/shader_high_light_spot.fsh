#define PI 3.14159265
#define TAU PI * 2.0
#define MAXSAMPLES 64

uniform sampler2D uTexture;
uniform float uAlpha;
uniform float uBrightness;

uniform vec3 uLightPosition;
uniform vec4 uLightColor;
uniform float uLightNear;
uniform float uLightFar;
uniform float uLightFadeSize;
uniform float uLightSpotSharpness;

uniform sampler2D uDepthBuffer;

uniform int uBlurQuality;
uniform float uBlurSize;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying float vBrightness;

float unpackDepth(vec4 c)
{
    return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

void main() 
{
    float dif = 0.0;
    float shadow = 0.0;
    
    // Check if not behind the spot light
    if (vScreenCoord.w > 0.0)
	{
        // Diffuse factor
        dif = max(0.0, dot(normalize(vNormal), normalize(uLightPosition - vPosition)));
        
        // Attenuation factor
        dif *= 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0);
        
        if (dif > 0.0 && uBrightness < 1.0)
		{
            float fragDepth = min(vScreenCoord.z, uLightFar);
            vec2 fragCoord = (vec2(vScreenCoord.x, -vScreenCoord.y) / vScreenCoord.z + 1.0) / 2.0;
            
            // Texture position must be valid
            if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0)
			{
                // Create circle
                dif *= 1.0 - clamp((distance(fragCoord, vec2(0.5, 0.5)) - 0.5 * uLightSpotSharpness) / (0.5 * max(0.01, 1.0 - uLightSpotSharpness)), 0.0, 1.0);
                
                // Calculate bias
                float bias = 0.1 * (uLightFar / fragDepth);
                
                // Calculate sample size
                float sampleSize = uBlurSize / fragDepth;
                
                // Find shadow                
                for (int i = 0; i < MAXSAMPLES; i++)
				{
                    if (i < uBlurQuality)
					{
                        // Sample from circle
                        float angle = (float(i) / float(uBlurQuality)) * TAU;
                        vec2 off = vec2(cos(angle), sin(angle));
                        
                        // Get sample depth
                        vec2 sampleCoord = fragCoord + off * sampleSize;
                        float sampleDepth = uLightNear + unpackDepth(texture2D(uDepthBuffer, sampleCoord)) * (uLightFar - uLightNear);
                        
                        // Add to shadow
                        shadow += (fragDepth - bias > sampleDepth) ? 1.0 : 0.0;
                    }
					else
                        break;
                }
                
                shadow /= float(uBlurQuality);
                
            } 
			else
                dif = 0.0;
        }
    }
    
    // Calculate light
    vec3 light = uLightColor.rgb * dif * (1.0 - shadow);
    light = mix(light, vec3(1.0), vBrightness + uBrightness);
    
    // Set final color
    vec4 baseColor = texture2D(uTexture, vTexCoord);
    gl_FragColor = vec4(light, uAlpha * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
