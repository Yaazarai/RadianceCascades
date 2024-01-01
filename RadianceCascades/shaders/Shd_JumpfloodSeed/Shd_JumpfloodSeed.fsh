varying vec2 in_FragCoord;

#define F16V2(f) vec2(floor(f * 255.0) * float(0.0039215686274509803921568627451), fract(f * 255.0))

void main() {
    vec4 scene = texture2D(gm_BaseTexture, in_FragCoord);
    gl_FragColor = vec4(F16V2(in_FragCoord.x * scene.a), F16V2(in_FragCoord.y * scene.a));
}