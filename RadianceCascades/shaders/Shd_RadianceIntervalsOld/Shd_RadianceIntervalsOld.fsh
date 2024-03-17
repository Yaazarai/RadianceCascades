varying vec2  in_TextCoord;
uniform float in_CascadeDiagonal;    // Cascade Pixel Resolution
uniform float in_RadianceInterval;   // Distance Between Radiance Probes in Cascade 0.
uniform float in_CascadeScaling;     // Resolution Scaling of Cascades.
uniform float in_CascadeIndex;       // Cascade Index to Calculate.

uniform vec2      in_RenderDiagonal; // Scren Space Resolution.
uniform sampler2D in_DistanceField;  // World Input Distance Field.
uniform sampler2D in_WorldScene;     // World Input Raymarch Scene.

void main() {}
/*
#define EPSILON       0.0001
#define TAU           float(6.2831853071795864769252867665590)
#define TONEMAP(c, d) (c.rgb * (1.0 / (1.0 + dot(d, d))))

// Raymarch from pos in direction dir for a max range (distance).
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
    // Convert fragment UV to pixel index within the current cascade.
	vec2 pixel = in_FragCoord * in_CascadeResolution;
    
	// Calculate the radiance interval according to the scaling ratio between cascades (2x, 4x, etc.).
	// Scalar to ScalarN1 is the sampling overlap between probes to avoid missing space between probe samples.
	float scalar = pow(in_CascadeScaling, in_CascadeIndex);
	float scalarN1 = pow(in_CascadeScaling, in_CascadeIndex+1.0);
	float interval = in_RadianceInterval * scalar;
	float range = in_RadianceInterval * scalarN1;
	
	// Find the texel space of the probe that this pixel resides
	// in and then find the corrosponding ray angle (theta).
	vec2  texel = mod(pixel, interval);
	float count = interval * interval;
	float index = (texel.y * interval) + texel.x;
	float theta = TAU * ((index + 0.5) / count);
	vec2 delta = vec2(cos(theta), -sin(theta));
	
	// Initial Radiance Probe X,Y position in space, evenly spaced and centered on grid cells.
	vec2 probe = in_FragCoord * in_Resolution;
	probe = vec2(floor(probe / interval) * interval) + vec2(interval * 0.5);
	// Adds delta + interval building starting ray position (except for cascade 0).
	float startInterval = interval * sign(in_CascadeIndex);
	vec2 ray = probe + vec2(delta * startInterval);
	
	vec2 ptexel = 1.0/in_Resolution;
	probe *= ptexel;
	ray *= ptexel;
	
	// Raymarch from Ray + Interval to End of Range, return result.
	float raydist = 0.0;
	vec3 radiance = raymarch(ray, delta, range, raydist);
	raydist = length((ray + (raydist * delta)) - probe);
	gl_FragColor = vec4(TONEMAP(radiance, raydist), 1.0);
	//gl_FragColor = vec4(texel/interval, 0.0, 1.0) + vec4(TONEMAP(radiance, raydist), 1.0);
}
*/
//
// Cascade Prob Texel Space:
//		gl_FragColor = vec4(texel/interval, 0.0, 1.0);
//
// Cascade Probe Emissive + Texel Space:
//		gl_FragColor = vec4(texel/interval, 0.0, 1.0) + vec4(radiance, 1.0);
//