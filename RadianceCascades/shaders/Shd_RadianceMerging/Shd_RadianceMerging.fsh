varying vec2 in_TextCoord;
uniform float in_CascadeExtent;   // Cascade Diagonal Resolution.
uniform float in_CascadeAngular;  // Cascade angular resolution.
uniform float in_CascadeCount;     // Total number of used cascades.
uniform float in_CascadeIndex;    // Cascade index.
uniform sampler2D in_CascadeAtlas; // Cascade Upper (N+1).

struct ProbeTexel {
	float count;
	float size;
	float index;
	vec2 texel;
	ivec2 probe;
};

ProbeTexel cascadeProbeTexel(ivec2 coord, float cascade) {
	float count = in_CascadeAngular * pow(4.0, cascade);
	float size = sqrt(count);
	vec2  texel = mod(vec2(coord), vec2(size));
	float index = floor((texel.y * size) + texel.x);
	ivec2 probe = coord / ivec2(size);
	return ProbeTexel(count, size, index, texel, probe);
}

vec4 cascadeFetch(ProbeTexel info, vec2 texelIndex, float thetaIndex) {
	vec2 probeTexel = texelIndex * info.size;
	probeTexel += vec2(mod(thetaIndex, info.size), thetaIndex / info.size);
	vec2 cascadeTexelPosition = probeTexel / in_CascadeExtent;
	return texture2D(in_CascadeAtlas, cascadeTexelPosition);
}

void main() {
	ivec2 cascadeCoord = ivec2(in_TextCoord * in_CascadeExtent);
	ProbeTexel probeInfo = cascadeProbeTexel(cascadeCoord, in_CascadeIndex);
	ProbeTexel probeInfoN1 = cascadeProbeTexel(cascadeCoord, in_CascadeIndex + 1.0);
	
	vec2 texelIndexN1 = floor((vec2(probeInfo.probe) - 1.0) / 2.0);
	vec2 texelIndexN1_N = floor((texelIndexN1 * 2.0) + 1.0);
	
	vec4 radiance = texture2D(gm_BaseTexture, in_TextCoord);
	
	if (radiance.a != 0.0) {
		vec4 TL = vec4(0.0), TR = vec4(0.0),
			BL = vec4(0.0), BR = vec4(0.0);
		
		// We always default to a 4x ray branch scaling between cascades.
		const float branch4 = 4.0;
		for(float i = 0.0; i < branch4; i++) {
			float thetaIndexN1 = (probeInfo.index * branch4) + i;
			TL += cascadeFetch(probeInfoN1, texelIndexN1 + vec2(0.0,0.0), thetaIndexN1);
			TR += cascadeFetch(probeInfoN1, texelIndexN1 + vec2(1.0,0.0), thetaIndexN1);
			BL += cascadeFetch(probeInfoN1, texelIndexN1 + vec2(0.0,1.0), thetaIndexN1);
			BR += cascadeFetch(probeInfoN1, texelIndexN1 + vec2(1.0,1.0), thetaIndexN1);
		}
		
		// Per Specification:
		//vec2 weight = vec2(0.25) + (vec2(probeInfo.probe) - texelIndexN1_N) * vec2(0.5);
		
		// Smoother Weights:
		vec2 weight = vec2(0.33) + (vec2(probeInfo.probe) - texelIndexN1_N) * vec2(0.33);
		
		vec4 interpolated = mix(mix(TL, TR, weight.x), mix(BL, BR, weight.x), weight.y);
		radiance.rgb += radiance.a * interpolated.rgb;
		radiance.a *= interpolated.a;
		radiance.rgb /= branch4;
	}
	
	gl_FragColor = radiance;
}