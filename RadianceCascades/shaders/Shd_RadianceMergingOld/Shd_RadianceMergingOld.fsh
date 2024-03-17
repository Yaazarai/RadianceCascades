varying vec2 in_FragCoord;
uniform vec2  in_CascadeResolution; // Cascade Pixel Resolution
uniform float in_RadianceInterval;  // Distance Between Radiance Probes in Cascade 0.
uniform float in_CascadeScaling;    // Resolution Scaling of Cascades.
uniform float in_CascadeIndex;      // Cascade Index to Calculate.

uniform vec2 in_Resolution;         // Scren Space Resolution.
uniform sampler2D in_CascadeN1;     // Cascade N+1 Texture.

#define DECAYRATE     0.95
#define EPSILON       0.0001
#define TAU           float(6.2831853071795864769252867665590)
#define V2F16(v)      ((v.y * float(0.0039215686274509803921568627451)) + v.x)
#define TONEMAP(c, d) (c.rgb * (1.0 / (1.0 + dot(d, d))))
#define BRIGHTNESS(v) sign(max(v.r, max(v.g, v.b)))

// 4-tap Interpolation between colors of a square.
vec3 composite(vec3 tl, vec3 tr, vec3 bl, vec3 br, vec2 uv) {
    return mix(mix(tl, tr, uv.x), mix(bl, br, uv.x), uv.y);
}

// Fetch the radiance interval (inteprolated rays 1-4) in cascade (N+1) in direction D from probe P (N).
vec3 cascadeFetch(vec2 probe, float theta, vec2 offset) {
	vec2 invResolution = 1.0 / in_CascadeResolution;
	float scalarN1 = pow(in_CascadeScaling, in_CascadeIndex + 1.0);
	float intervalN1 = in_RadianceInterval * scalarN1;
	vec2 probeN1 = vec2(floor(probe / intervalN1) * intervalN1);
	
	vec2 center = vec2(intervalN1 * 0.5);
	vec2 delta = sign(probe - (probeN1 + center));
	probeN1 += delta * offset;
	
	float countN1 = intervalN1 * intervalN1;
	float indexN1 = floor(theta * countN1);
	
	vec2 texel0 = vec2(mod(indexN1 + 0.0, intervalN1), (indexN1 + 0.0) / intervalN1);
	vec2 texel1 = vec2(mod(indexN1 + 1.0, intervalN1), (indexN1 + 1.0) / intervalN1);
	vec2 texel2 = vec2(mod(indexN1 + 2.0, intervalN1), (indexN1 + 2.0) / intervalN1);
	vec2 texel3 = vec2(mod(indexN1 + 3.0, intervalN1), (indexN1 + 3.0) / intervalN1);
	
	vec3 ray0 = texture2D(in_CascadeN1, (probeN1 + texel0) * invResolution).rgb;
	vec3 ray1 = texture2D(in_CascadeN1, (probeN1 + texel1) * invResolution).rgb;
	vec3 ray2 = texture2D(in_CascadeN1, (probeN1 + texel2) * invResolution).rgb;
	vec3 ray3 = texture2D(in_CascadeN1, (probeN1 + texel3) * invResolution).rgb;
	
	float bright = BRIGHTNESS(ray0) + BRIGHTNESS(ray1) + BRIGHTNESS(ray2) + BRIGHTNESS(ray3);
	//return (ray0 + ray1 + ray2 + ray3) / bright;
	return vec3(texel0 / intervalN1, 0.0);
}

void main() {
	vec2 pixel = in_FragCoord * in_CascadeResolution;
	float scalar = pow(in_CascadeScaling, in_CascadeIndex);
	float interval = in_RadianceInterval * scalar;
	vec2 probe = vec2(floor(pixel / interval) * interval) + vec2(interval * 0.5);
	
	vec2  texel = mod(pixel, interval);
	float count = interval * interval;
	float index = (texel.y * interval) + texel.x;
	float theta = index / count;
	
	vec3 probe00 = cascadeFetch(probe, theta, vec2(0.0,0.0));
	vec3 probe10 = cascadeFetch(probe, theta, vec2(1.0,0.0));
	vec3 probe01 = cascadeFetch(probe, theta, vec2(0.0,1.0));
	vec3 probe11 = cascadeFetch(probe, theta, vec2(1.0,1.0));
	
	vec3 radiance = texture2D(gm_BaseTexture, in_FragCoord).rgb;
	float brightness = sign(max(radiance.r, max(radiance.g, radiance.b)));
	vec3 radianceN1 = composite(probe00, probe10, probe01, probe11, vec2(0.25, 0.25));
	brightness += sign(max(radianceN1.r, max(radianceN1.g, radianceN1.b)));
	//gl_FragColor =  vec4(radiance / brightness, 1.0);
	gl_FragColor =  vec4(probe00, 1.0);
}