varying vec2 in_FragCoord;
/*
uniform float in_CascadeResolution; // Cascade Pixel Resolution
uniform float in_AngularResolution; // Pixel Resolution, RayCount = sqr(AngularRes)
uniform float in_RadianceInterval;  // Distance Between Radiance Probes in Cascade 0.
uniform float in_IntervalOverlap;   // Radiance Interval Overlap Between Probes.
uniform float in_CascadeScaling;    // Resolution Scaling of Cascades.
uniform float in_CascadeIndex;      // Cascade Index to Calculate.
*/
void main() {
    vec4 scene = texture2D(gm_BaseTexture, in_FragCoord);
    /*
	float interval = max(in_RadianceInterval, in_RadianceInterval * in_CascadeIndex * in_CascadeScaling);
	float interval_length = interval * in_IntervalOverlap;
	
	vec2 pixel = in_FragCoord * in_CascadeResolution;
	vec2 subpos = vec2(mod(pixel, interval), mod(pixel, interval));
	float index = (subpos.y * interval) + subpos.x;
	float theta = TAU * (index/interval);
	*/
	gl_FragColor = scene;
}