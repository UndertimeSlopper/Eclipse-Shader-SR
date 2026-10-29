// swap out jitter pattern to be a 4 frame pattern instead of an 8 frame halton sequence
#if defined RESPONSIVE_TAA || defined DH_TAA_OVERRIDE
	const vec2[4] offsets = vec2[4](
		vec2(-0.125,	-0.875),
		vec2( 0.875,	-0.125),
		vec2( 0.125,	 0.875),
		vec2(-0.875,	 0.125)
	);
#else
	const vec2[8] offsets = vec2[8](
	    vec2( 1.0, -3.0)/8.0,
		vec2(-1.0,  3.0)/8.0,
		vec2( 5.0,  1.0)/8.0,
		vec2(-3.0, -5.0)/8.0,
		vec2(-5.0,  5.0)/8.0,
		vec2(-7.0, -1.0)/8.0,
		vec2( 3.0,  7.0)/8.0,
		vec2( 7.0,  7.0)/8.0
	);
#endif

// jitter of the current frame, in the same units as the offsets above
#ifdef SUPER_RESOLUTION
	// the Super Resolution mod picks the jitter (in pixels), see shaders.properties
	#ifndef VOXY_PROGRAM
		uniform vec2 srJitterOffset;
	#endif
	#define TAA_JITTER (srJitterOffset * 2.0)
	#define TAA_JITTER_DH (srJitterOffset * 2.0)
#else
	#define TAA_JITTER offsets[framemod8]
	#define TAA_JITTER_DH offsets[framemod4_DH]
#endif