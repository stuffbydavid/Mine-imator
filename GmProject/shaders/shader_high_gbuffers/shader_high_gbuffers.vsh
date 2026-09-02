attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

uniform float uFar; // static
uniform float uNear; // static

uniform vec4 uBlendColor;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec3 vNormalView;
varying vec3 vTangentView;
varying vec3 vNormalWorld;
varying vec3 vTangentWorld;
varying vec4 vColor;
varying vec4 vCustom;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)
#pragma shady: inline(common_util.MATRIX_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vTexCoord = in_TextureCoord + uTextureOffset;
	
	gl_Position = getClipPosition(vPosition);
	
	// Depth
	vec4 depthPos = (gm_Matrices[MATRIX_VIEW] * vec4(vPosition, 1.0));
	vDepth = ((depthPos.z - uNear) / (uFar - uNear));
	
	// Create vectors for TBN matrix
	mat3 worldViewInv = inverse2(gm_Matrices[MATRIX_WORLD_VIEW]);
	vNormalView = normalize(worldViewInv * in_Normal);
	vTangentView = normalize(worldViewInv * in_Tangent);
	vNormalWorld = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vTangentWorld = (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangent, 0.0)).xyz;
	
	// Color
	vColor = uBlendColor * in_Colour;
	vCustom = in_Wave;
}
