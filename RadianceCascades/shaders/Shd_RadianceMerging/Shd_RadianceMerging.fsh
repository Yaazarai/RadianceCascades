varying vec2 in_TextCoord;
uniform float in_CascadeExtent;   // Cascade Diagonal Resolution.
uniform float in_CascadeSpacing;  // Cascade 0 probe spacing.
uniform float in_CascadeInterval; // Cascade 0 radiance interval.
uniform float in_CascadeIndex;    // Cascade index.
uniform float in_CascadeAngular;  // Cascade angular resolution.
uniform float in_CascadeCount;     // Total number of used cascades.
uniform sampler2D in_CascadeUpper; // Cascade Upper (N+1).

void main() {
	
}
/*
struct ProbeTexel {
	float count;   // number of ray-directions in this probe.
	ivec2 probe;   // the cell index of this probe.
	ivec2 spacing; // spacing between radiance probes.
	float index;   // the theta-index of this texel in it's probe.
	float minimum; // minimum interval-range.
	float maximum; // maximum interval-range.
	float texel;   // texel size: 1.0 / cascadeExtent;
	vec2 position; // cascade texel probe position.
};

ProbeTexel cascadeProbeTexel(ivec2 coord, float cascade) {
	float count = in_CascadeAngular * pow(4.0, cascade);
	float size = sqrt(count);
	ivec2 probe = coord / ivec2(size);
	ivec2 spacing = ivec2(in_CascadeSpacing * pow(2.0, cascade));
	
	vec2  probePos = mod(vec2(coord), vec2(size));
	float index = (probePos.y * size) + probePos.x;
	
	float minimum = in_CascadeInterval * pow(4.0, cascade - 1.0) * sign(cascade);
	float maximum = in_CascadeInterval * pow(4.0, cascade);
	float texel = 1.0 / in_RenderExtent;
	
	return ProbeTexel(count, probe, spacing, index, minimum, maximum, texel, probePos / vec2(size));
}

void main() {
	ivec2 texel = ivec2(in_TextCoord * vec2(in_CascadeExtent));
	ProbeTexel probeInfo = cascadeProbeTexel(texel, in_CascadeIndex);
	ProbeTexel probeInfoN1 = cascadeProbeTexel(texel, in_CascadeIndex);
}
*/
/*
struct TexelInfo {
	int texelAngles;
	int texelSize;
	int texelCount;
};

TexelInfo cascadeTexelInfo(int cascadeIndex) {
	float texelAngles = in_CascadeAngular * pow(4.0, float(cascadeIndex));
	float texelSize = sqrt(texelAngles);
	float texelCount = in_CascadeExtent / texelSize;
	return TexelInfo(int(texelAngles), int(texelSize), int(texelCount));
}

vec4 cascadeFetch(TexelInfo info, ivec2 texelIndex, int thetaIndex) {
	ivec2 probeTexel = texelIndex * info.texelSize;
	probeTexel += ivec2(int(mod(float(thetaIndex), float(info.texelSize))), thetaIndex / info.texelSize);
	vec2 cascadeTexelPosition = vec2(probeTexel) / in_CascadeExtent;
	return texture2D(in_CascadeUpper, cascadeTexelPosition);
}

void main() {
	ivec2 cascadeCoord = ivec2(in_TextCoord * in_CascadeExtent);
	int cascadeIndexN1 = int(in_CascadeIndex) + 1;
	
	TexelInfo cascadeTexel = cascadeTexelInfo(int(in_CascadeIndex));
	TexelInfo cascadeTexelN1 = cascadeTexelInfo(cascadeIndexN1);
	
	ivec2 texelIndex = cascadeCoord / cascadeTexel.texelSize;
	ivec2 texelPosition = ivec2(mod(float(cascadeCoord), float(cascadeTexel.texelSize)));
	texelPosition /= cascadeTexel.texelSize;
	texelPosition *= cascadeTexelN1.texelSize;
	
	// Get texel index of upper-left nearest probe.
	ivec2 texelIndexN1 = (texelIndex - 1) / 2;
	ivec2 texelIndexN1_N = (texelIndexN1 * 2) + 1;
	
	// Get thetaIndex of cascadeN, multiply by cascadeN1.texelAngles for the 4x angular resolution of cascade N+1.
	int thetaIndexN1 = ((texelPosition.y * cascadeTexelN1.texelSize) + texelPosition.x);
	
	// Get the current rasdiance interval from the previous pass.
	vec4 radiance = texture2D(gm_BaseTexture, in_TextCoord) * 2.0;
	
	// We always default to a 4x ray branch scaling between cascades.
	const int branch4 = 4;
	thetaIndexN1 *= branch4;
	for(int i = 0; i < branch4; i++) {
		vec4 radianceTL = cascadeFetch(cascadeTexelN1, texelIndexN1+ivec2(0,0), thetaIndexN1+i);
		vec4 radianceTR = cascadeFetch(cascadeTexelN1, texelIndexN1+ivec2(1,0), thetaIndexN1+i);
		vec4 radianceBL = cascadeFetch(cascadeTexelN1, texelIndexN1+ivec2(0,1), thetaIndexN1+i);
		vec4 radianceBR = cascadeFetch(cascadeTexelN1, texelIndexN1+ivec2(1,1), thetaIndexN1+i);
		
		vec2 weight = vec2(0.25) + step(vec2(texelIndexN1), vec2(texelIndexN1_N)) * vec2(0.5);
		vec4 interpolated = mix(mix(radianceTL, radianceTR, weight.x), mix(radianceBL, radianceBR, weight.x), weight.y);
		radiance += interpolated;
	}
	
	gl_FragColor = radiance / float(branch4);
}
*/