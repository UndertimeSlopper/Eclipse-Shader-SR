#include "/lib/settings.glsl"

#if RESOURCEPACK_SKY != 0
	#include "/lib/res_params.glsl"
	/*
	!! DO NOT REMOVE !!
	This code is from Chocapic13' shaders
	Read the terms of modification and sharing before changing something below please !
	!! DO NOT REMOVE !!
	*/
	out vec4 color;
	out vec2 texcoord;
	uniform vec2 texelSize;
	uniform int framemod8;
	const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
								vec2(-1.,3.)/8.,
								vec2(5.0,1.)/8.,
								vec2(-3,-5.)/8.,
								vec2(-5.,5.)/8.,
								vec2(-7.,-1.)/8.,
								vec2(3,7.)/8.,
								vec2(7.,-7.)/8.);

	#ifdef SUPER_RESOLUTION
		// the jitter of this frame, picked by the Super Resolution mod (see /lib/TAA_jitter.glsl)
		uniform vec2 srJitterOffset;
	#endif
#endif

void main() {
	gl_Position = ftransform();
	
	#if RESOURCEPACK_SKY != 0

		texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
		color = gl_Color;

		#if defined TAA_UPSCALING || defined SUPER_RESOLUTION
			gl_Position.xy = gl_Position.xy * RENDER_SCALE + RENDER_SCALE * gl_Position.w - gl_Position.w;
		#endif
		#ifdef TAA
			#ifdef SUPER_RESOLUTION
				gl_Position.xy += srJitterOffset * 2.0 * gl_Position.w*texelSize;
			#else
				gl_Position.xy += offsets[framemod8] * gl_Position.w*texelSize;
			#endif
		#endif
		
	#endif
}