varying vec2 in_FragCoord;
uniform vec2  in_CascadeResolution; // Cascade Pixel Resolution
uniform float in_RadianceInterval;  // Distance Between Radiance Probes in Cascade 0.
uniform float in_IntervalOverlap;   // Radiance Interval Overlap Between Probes.
uniform float in_CascadeScaling;    // Resolution Scaling of Cascades.
uniform float in_CascadeIndex;      // Cascade Index to Calculate.

uniform vec2 in_Resolution;
uniform sampler2D in_DistanceField;
uniform sampler2D in_WorldScene;

#define DECAYRATE  0.95
#define EPSILON  0.0001
#define TAU      float(6.2831853071795864769252867665590)
#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

vec3 raymarch(vec2 pos, vec2 dir, float range, out float raydist) {
	range = range/length(in_Resolution);
	vec2 aspect = vec2(in_Resolution.y / in_Resolution.x, 1.0 / (in_Resolution.y / in_Resolution.x));
	pos *= vec2(aspect.x, 1.0);
	
	for(float d = 0.0, i = 0.0; i < range; i++) {
		vec2 ray = (pos + (dir * raydist)) * vec2(aspect.y, 1.0);
		raydist += d = V2F16(texture2D(in_DistanceField, ray).rg);
		
		if (d <= EPSILON || raydist >= range)
			return texture2D(in_WorldScene, ray).rgb;
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
	vec2 delta = vec2(cos(theta), -sin(theta));
	
	vec2 ray = in_FragCoord * in_Resolution;
	ray = (floor(ray / interval) * interval) + (interval * 0.5) + (delta * interval);
	ray *= (1.0/in_Resolution);
	
	float raydist = 0.0;
	vec3 emissive = raymarch(ray, delta, range, raydist);
	emissive *= 1.0 / (1.0 + dot(raydist, raydist));
	gl_FragColor = vec4(emissive, 1.0);
}

//
// Cascade Prob Texel Space:
//		gl_FragColor = vec4(texel/interval, 0.0, 1.0);
//
// Cascade Probe Emissive + Texel Space:
//		gl_FragColor = vec4(texel/interval, 0.0, 1.0) + vec4(emissive, 1.0);
//