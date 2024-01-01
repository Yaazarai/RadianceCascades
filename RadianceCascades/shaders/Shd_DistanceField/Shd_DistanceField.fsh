varying vec2 in_FragCoord;
uniform vec2 in_Resolution;

// Convert V2 to F16:
#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

// Convert F16 to V2:
#define F16V2(f) vec2(floor(f * 255.0) * float(0.0039215686274509803921568627451), fract(f * 255.0))

void main() {
    // Distance Field from Jumpflood Texture:
	vec4 jfuv = texture2D(gm_BaseTexture, in_FragCoord);
    vec2 jumpflood = vec2(V2F16(jfuv.rg),V2F16(jfuv.ba));
    float dist = distance(in_FragCoord, jumpflood);
	
	// Distance Field Skew Correction by Dominant Resolution Axis:
	float reslo = min(in_Resolution.y, in_Resolution.x);
	float reshi = max(in_Resolution.x, in_Resolution.y);
	dist *= reslo / reshi;
	
	// Two-Byte Color encoded distance field:
	gl_FragColor = vec4(F16V2(dist), 0.0, 1.0);
}