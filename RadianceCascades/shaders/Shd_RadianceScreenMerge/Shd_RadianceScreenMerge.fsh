varying vec2 in_TextCoord;
uniform float in_RenderExtent;    // Screen Diaognal Resolution.
uniform float in_MipMapExtent;    // Cascade Diagonal Resolution.
uniform sampler2D in_MipMapAtlas; // Cascade Upper (N+1).

void main() {
	vec2 pixelCoord = in_TextCoord * in_RenderExtent;
	vec2 mipCoord = in_TextCoord * in_MipMapExtent;
	vec2 mipTL = mipCoord + vec2(0.0, 0.0);
	vec2 mipTR = mipCoord + vec2(1.0, 0.0);
	vec2 mipBL = mipCoord + vec2(0.0, 1.0);
	vec2 mipBR = mipCoord + vec2(1.0, 1.0);
	
	vec4 TL = texture2D(in_MipMapAtlas, mipTL / in_MipMapExtent);
	vec4 TR = texture2D(in_MipMapAtlas, mipTR / in_MipMapExtent);
	vec4 BL = texture2D(in_MipMapAtlas, mipBL / in_MipMapExtent);
	vec4 BR = texture2D(in_MipMapAtlas, mipBR / in_MipMapExtent);
	
	vec2 cellSize = vec2(floor(in_RenderExtent / in_MipMapExtent));
	vec2 weight = mod(pixelCoord, cellSize) / cellSize;
	vec4 interpolated = mix(mix(TL, TR, weight.x), mix(BL, BR, weight.x), weight.y);
	gl_FragColor = interpolated * 2.0;
}