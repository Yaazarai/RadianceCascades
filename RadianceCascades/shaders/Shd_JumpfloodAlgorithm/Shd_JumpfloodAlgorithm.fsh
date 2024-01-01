varying vec2  in_FragCoord;
uniform float in_JumpDistance;
uniform vec2 in_Resolution;

#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

void main() {
	vec2 offsets[9];
	offsets[0] = vec2(-1.0, -1.0);
	offsets[1] = vec2(-1.0, 0.0);
	offsets[2] = vec2(-1.0, 1.0);
	offsets[3] = vec2(0.0, -1.0);
	offsets[4] = vec2(0.0, 0.0);
	offsets[5] = vec2(0.0, 1.0);
	offsets[6] = vec2(1.0, -1.0);
	offsets[7] = vec2(1.0, 0.0);
    offsets[8] = vec2(1.0, 1.0);
    
    float closest_dist = 9999999.9;
    vec2 closest_pos = vec2(0.0);
    vec4 closest_data = vec4(0.0);
    
    for(int i = 0; i < 9; i++) {
        vec2 jump = in_FragCoord + (offsets[i] * vec2(in_JumpDistance / in_Resolution));
        vec4 seed = texture2D(gm_BaseTexture, jump);
        vec2 seedpos = vec2(V2F16(seed.xy), V2F16(seed.zw));
        float dist = distance(seedpos, in_FragCoord);
        
        if (seedpos != vec2(0.0) && dist <= closest_dist) {
            closest_dist = dist;
            closest_data = seed;
        }
    }
    
    gl_FragColor = closest_data;
}