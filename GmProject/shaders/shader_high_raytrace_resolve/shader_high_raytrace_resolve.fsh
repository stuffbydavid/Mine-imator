#define DEPTH_SENSITIVITY 40.0

varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uMaterialBuffer;

uniform int uIndirect;

uniform vec2 uScreenSize;
uniform float uSampleIndex;

#pragma shady: inline(common_util.UNPACK_VALUE_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)

vec4 sampleNeighbor(vec2 samplePos, vec3 originNormal, float originDepth, vec3 originMat)
{
	if (samplePos.x < 0.0 || samplePos.x > 1.0 || samplePos.y < 0.0 || samplePos.y > 1.0)
		return vec4(0.0);
	
	vec3 sampleNormal = unpackNormal(texture2D(uNormalBuffer, samplePos));
	float sampleDepth = unpackValue(texture2D(uDepthBuffer, samplePos));
	vec3 sampleMat = (uIndirect > 0 ? vec3(0.0) : texture2D(uMaterialBuffer, samplePos).rgb);
	
	float sampleWeight = clamp(dot(originNormal, sampleNormal) - abs(sampleMat.b - originMat.b) - abs(sampleDepth - originDepth) * DEPTH_SENSITIVITY, 0.0, 1.0);
	return vec4(texture2D(gm_BaseTexture, samplePos).rgb * sampleWeight, sampleWeight);
}

void main()
{
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	vec3 originMat = (uIndirect > 0 ? vec3(0.0) : texture2D(uMaterialBuffer, vTexCoord).rgb);
	
	float pixel = (floor(vTexCoord.x * uScreenSize.x) + floor(vTexCoord.y * uScreenSize.y)) + uSampleIndex;
	bool halfResCast = (mod(pixel, 2.0) == 0.0);
	if (!halfResCast && (originMat.b > 0.001 || uIndirect > 0))
	{
		vec4 sampleColor = vec4(0.0);
		vec3 originNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
		float originDepth = unpackValue(texture2D(uDepthBuffer, vTexCoord));
		
		vec2 texelSize = 1.0 / uScreenSize;
		
		sampleColor += sampleNeighbor(vTexCoord + vec2(texelSize.x, 0.0), originNormal, originDepth, originMat);
		sampleColor += sampleNeighbor(vTexCoord + vec2(-texelSize.x, 0.0), originNormal, originDepth, originMat);
		sampleColor += sampleNeighbor(vTexCoord + vec2(0.0, texelSize.y), originNormal, originDepth, originMat);
		sampleColor += sampleNeighbor(vTexCoord + vec2(0.0, -texelSize.y), originNormal, originDepth, originMat);
		
		if (sampleColor.a > 0.01)
			color.rgb = sampleColor.rgb / sampleColor.a;
	}
	
	gl_FragColor = color;
}
