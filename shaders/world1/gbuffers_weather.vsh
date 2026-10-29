#version 430 compatibility
#define TAA

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

out vec4 lmtexcoord;
out vec4 color;

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

// Super Resolution mod, same check as in /lib/settings.glsl which this program does not include
#if defined SR_ENABLE && defined SR_ALGO_NONE
	#if SR_ENABLE == 1 && SR_SHOULD_APPLY_SCALE == 1 && SR_USING_ALGO != SR_ALGO_NONE && SR_ALGO_SUPPORTS_JITTER == 1
		#define SUPER_RESOLUTION 1
		uniform vec2 srJitterOffset;
	#endif
#endif
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	lmtexcoord.xy = (gl_MultiTexCoord0).xy;

	vec2 lmcoord = gl_MultiTexCoord1.xy / 240.0;
	lmtexcoord.zw = lmcoord*lmcoord;

	
	gl_Position = ftransform();
	
	color = gl_Color;
	#ifdef SUPER_RESOLUTION
	gl_Position.xy = gl_Position.xy * SR_RENDER_SCALE_FACTOR + SR_RENDER_SCALE_FACTOR * gl_Position.w - gl_Position.w;
	gl_Position.xy += srJitterOffset * 2.0 * gl_Position.w*texelSize;
	#else
	#ifdef TAA
	gl_Position.xy += offsets[framemod8] * gl_Position.w*texelSize;
	#endif
	#endif
}