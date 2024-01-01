varying vec2 in_FragCoord;
uniform vec2  in_CascadeResolution; // Cascade Pixel Resolution
uniform float in_RadianceInterval;  // Distance Between Radiance Probes in Cascade 0.
uniform float in_IntervalOverlap;   // Radiance Interval Overlap Between Probes.
uniform float in_CascadeScaling;    // Resolution Scaling of Cascades.
uniform float in_CascadeIndex;      // Cascade Index to Calculate.

uniform vec2 in_Resolution;
uniform sampler2D in_DistanceField;
uniform sampler2D in_WorldScene;

#define DECAYRATE 0.95 // Light absorption decay from implicit ray bounces: 0.85 - 0.95 optimal.
#define EPSILON  0.0001
#define TAU      float(6.2831853071795864769252867665590)
#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

vec3 raymarch(vec2 pix, vec2 dir, float steps, out vec2 endpoint) {
	vec2 start = pix;
	for(float dist = 0.0, i = 0.0; i < steps; i += 1.0, pix += dir * dist) {
		vec2 sdf = texture2D(in_DistanceField, pix).rg;
		endpoint = pix;
		
		float raydist = length(vec2(pix - start) * in_Resolution);
		
		if ((dist = V2F16(sdf)) < EPSILON || raydist >= steps) {
			pix = start + (dir * min(raydist, steps)) * (1.0/in_Resolution);
			endpoint = pix;
			return texture2D(in_WorldScene, pix).rgb;
		}
	}
	return vec3(0.0);
}

void main() {
    vec2 pixel = in_FragCoord * in_CascadeResolution;
    
	float scalar = pow(in_CascadeScaling, in_CascadeIndex);
	float interval = in_RadianceInterval * scalar;
	float range = interval * in_IntervalOverlap;
	
	vec2  texel = vec2(mod(pixel, interval));
	float count = interval * interval;
	float index = (texel.y * interval) + texel.x;
	float theta = TAU * ((index + 0.5) / count);
	vec2 delta = vec2(cos(theta),-sin(theta));
	
	vec2 ray = in_FragCoord * in_Resolution;
	ray = (floor(ray / interval) * interval) + (interval * 0.5) + (delta * interval);
	ray *= (1.0 / in_Resolution);
	
	vec2 endpoint = vec2(ray);
	vec3 emissive = raymarch(ray, delta, range, endpoint);
	float raydist = length(endpoint - ray);
	emissive *= 1.0 / (1.0 + dot(raydist, raydist));
	gl_FragColor = vec4(emissive, 1.0);
}