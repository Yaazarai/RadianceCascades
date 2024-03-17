varying vec2 in_FragCoord;
uniform float in_CascadeResolution; // Cascade Pixel Resolution.
uniform float in_RadianceInterval;  // Distance Between Radiance Probes in Cascade 0.
uniform float in_CascadeScaling;    // Resolution Scaling of Cascades.

uniform vec2 in_Resolution;         // Scren Space Resolution.
uniform float in_CascadeIndex;      // Cascade Index to Calculate.
uniform sampler2D in_Cascade;       // Cascade Sampler2D surface.

#define TAU float(6.2831853071795864769252867665590)
#define PI  float(3.1415926535897932384626433832795)
#define ATAN2(d) ((atan(-d.y, -d.x) / PI) * .5) + .5
#define INVERSE(d) (1.0 / d)
#define TONEMAP(c, d) (c.rgb * (1.0 / (1.0 + dot(d, d))))

vec3 composite(vec3 tl, vec3 tr, vec3 bl, vec3 br, vec2 uv) {
    return mix(mix(tl, tr, uv.x), mix(bl, br, uv.x), uv.y);
}

vec3 probelookup(vec2 pixel, vec2 direct, float interval, float theta) {
	vec2 probe = floor(vec2(pixel + (interval * 0.5)) / interval) * interval;
	vec2 delta = sign(probe - pixel);
	probe += (delta * -direct) * interval;
	
	float count = interval * interval;
	float index = theta * count;
	vec2 texel = vec2(mod(index, interval), index / interval);
	probe += texel;
	
	vec3 radiance = texture2D(in_Cascade, probe / in_Resolution).rgb;
	float raydist = length(probe - pixel) * INVERSE(length(in_Resolution));
	return TONEMAP(radiance, raydist * INVERSE(in_Resolution));
}

void main() {
	vec2 pixel = in_FragCoord * in_Resolution;
	
	float scalar = pow(in_CascadeScaling, in_CascadeIndex);
	float interval = in_RadianceInterval * scalar;
	float count = interval * interval;
	vec2 probe = floor(vec2(pixel + (interval * 0.5)) / interval) * interval + (interval * 0.5);
	float theta = ATAN2(vec2(probe - pixel));
	
	vec3 probe00 = probelookup(pixel, vec2(-1.0, -1.0), interval, theta);
	vec3 probe10 = probelookup(pixel, vec2(1.0, 0.0), interval, theta);
	vec3 probe01 = probelookup(pixel, vec2(0.0, 1.0), interval, theta);
	vec3 probe11 = probelookup(pixel, vec2(1.0, 1.0), interval, theta);
	
	vec2 uvpixel = mod(abs(probe - pixel), interval) / interval;
	vec3 radiance = composite(probe00, probe10, probe01, probe11, uvpixel);
	vec3 source = texture2D(gm_BaseTexture, in_FragCoord).rgb;
	
	float brightness = max(radiance.r, max(radiance.g, radiance.b));
	brightness += max(source.r, max(source.g, source.b));
	radiance = ((source + radiance) / brightness) * (brightness / 2.0);
	gl_FragColor = vec4(radiance, 1.0);
}