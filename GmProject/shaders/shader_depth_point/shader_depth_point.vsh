/// @desc Renders to a point light depth buffer.

/// CppOnly #define CPP_POINT_MULTIVIEW
/// CppOnly uniform int _pointMultiview; // static

attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
attribute vec4 in_Wave;
attribute vec3 in_Tangent;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

uniform vec4 uBlendColor;

// Texture
uniform vec2 uTextureOffset;

#pragma shady: inline(common_position.WORLD_POSITION_LIB)
#pragma shady: inline(common_position.CLIP_POSITION_LIB)

void main()
{
	vPosition = getWorldPosition(in_Position, in_Wave);
	vTexCoord = in_TextureCoord + uTextureOffset;
	vColor = uBlendColor * in_Colour;
	
	/// CppOnly if (_pointMultiview > 0) {
	/// CppOnly gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
	/// CppOnly } else {
	gl_Position = getClipPosition(vPosition);
	/// CppOnly }
}
