varying vec2 in_FragCoord;
uniform vec2 in_Resolution;

// Convert VEC2 to FLOAT (16-BIT):
#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

// Convert FLOAT (16-BIT) to VEC2:
#define F16V2(f) vec2(floor(f * 255.0) * float(0.0039215686274509803921568627451), fract(f * 255.0))

void main() {
    // Distance Field from Jumpflood Texture:
	vec4 jfuv = texture2D(gm_BaseTexture, in_FragCoord);
    vec2 jumpflood = vec2(V2F16(jfuv.rg),V2F16(jfuv.ba));
	float uvdist = length(jumpflood - in_FragCoord);
	
	// Two-Byte Color encoded distance field:
	gl_FragColor = vec4(F16V2(uvdist), 0.0, 1.0);
}