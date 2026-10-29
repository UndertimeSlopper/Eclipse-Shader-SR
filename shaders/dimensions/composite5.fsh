#include "/lib/settings.glsl"

#ifdef SUPER_RESOLUTION
// while the Super Resolution mod upscales (see superresolution.v3.json), this pass makes the motion vectors it needs
// instead of the min/max for the TAA upscaler. like before, it only covers the render scale area.

#include "/lib/res_params.glsl"
#include "/lib/SSBOs.glsl"

uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex;
	#define dhVoxyDepthTex dhDepthTex
#endif

#ifdef VOXY
	uniform sampler2D vxDepthTexTrans;
	#define dhVoxyDepthTex vxDepthTexTrans
#endif

uniform vec2 texelSize;
uniform float near;
uniform float far;
uniform float dhVoxyFarPlane;
uniform float dhVoxyNearPlane;

uniform vec3 previousCameraPosition;
uniform mat4 gbufferPreviousModelView;

#include "/lib/util.glsl"
#include "/lib/projections.glsl"
#include "/lib/DistantHorizons_projections.glsl"
#include "/lib/TAA_jitter.glsl"

vec2 decodeVec2(float a){
    const vec2 constant1 = 65535. / vec2( 256., 65536.);
    const float constant2 = 256. / 255.;
    return fract( a * constant1 ) * constant2 ;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* RENDERTARGETS:19 */
	ivec2 pixel = ivec2(gl_FragCoord.xy);

	// screen position of what is in this pixel, without the jitter of this frame
	vec2 texcoord = (gl_FragCoord.xy*texelSize - TAA_JITTER*texelSize*0.5)/RENDER_SCALE;

	float z = texelFetch(depthtex0, pixel, 0).x;

	#if defined DISTANT_HORIZONS || defined VOXY
		bool depthCheck = z >= 1.0;
		vec3 viewPos = toScreenSpace_DH(texcoord, z, texelFetch(dhVoxyDepthTex, pixel, 0).x);
	#else
		vec3 viewPos = toScreenSpace(vec3(texcoord, z));
	#endif

	vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
	vec3 previousPosition = mat3(gbufferPreviousModelView) * playerPos + gbufferPreviousModelView[3].xyz;

	#if defined DISTANT_HORIZONS || defined VOXY
		mat4 previousProjection = depthCheck ? dhVoxyProjectionPrev : gbufferPreviousProjection;
	#else
		mat4 previousProjection = gbufferPreviousProjection;
	#endif
	previousPosition = projMAD(previousProjection, previousPosition) / -previousPosition.z * 0.5 + 0.5;

	// the hand moves with the camera
	float dataUnpacked = decodeVec2(texelFetch(colortex1, pixel, 0).w).y;
	bool hand = abs(dataUnpacked-0.75) < 0.01 && texelFetch(depthtex1, pixel, 0).x < 1.0;

	// previous minus current position, in screen space
	gl_FragData[0] = vec4(hand ? vec2(0.0) : previousPosition.xy - texcoord, 0.0, 1.0);
}

#else

uniform sampler2D colortex3;

uniform vec2 texelSize;
uniform int framemod8;
#include "/lib/TAA_jitter.glsl"
// Compute 3x3 min max for TAA

uniform float viewHeight;
uniform float viewWidth;


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* RENDERTARGETS:0,6 */
  vec2 screenEdges = 2.0/vec2(viewWidth, viewHeight);
  vec2 jitter = offsets[framemod8]*texelSize*0.5;
  ivec2 center = ivec2(clamp(gl_FragCoord.xy*texelSize, screenEdges, 1.0-screenEdges)/texelSize);

	// vec3 current = texelFetch(colortex3, center, 0).rgb;
  // vec3 cMin = current;
  // vec3 cMax = current;
  // current = texelFetch(colortex3, center + ivec2(-1, -1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(-1, 0), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(-1, 1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(0, -1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(0, 1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(1, -1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(1, 0), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // current = texelFetch(colortex3, center + ivec2(1, 1), 0).rgb;
  // cMin = min(cMin, current);
  // cMax = max(cMax, current);
  // gl_FragData[0].rgb = cMax;
  // gl_FragData[1].rgb = cMin;

  vec3 col0 = texelFetch(colortex3, center, 0).rgb;
  vec3 col1 = texelFetch(colortex3, center + ivec2(1, 1), 0).rgb;
  vec3 col2 = texelFetch(colortex3, center + ivec2(1, -1), 0).rgb;
  vec3 col3 = texelFetch(colortex3, center + ivec2(-1, -1), 0).rgb;
  vec3 col4 = texelFetch(colortex3, center + ivec2(-1, 1), 0).rgb;
  vec3 col5 = texelFetch(colortex3, center + ivec2(0, 1), 0).rgb;
  vec3 col6 = texelFetch(colortex3, center + ivec2(0, -1), 0).rgb;
  vec3 col7 = texelFetch(colortex3, center + ivec2(-1, 0), 0).rgb;
  vec3 col8 = texelFetch(colortex3, center + ivec2(1, 0), 0).rgb;

	vec3 colMax = max(col0,max(col1,max(col2,max(col3, max(col4, max(col5, max(col6, max(col7, col8))))))));
	vec3 colMin = min(col0,min(col1,min(col2,min(col3, min(col4, min(col5, min(col6, min(col7, col8))))))));

	vec3 colMax5 = max(col0,max(col5,max(col6,max(col7,col8))));
	vec3 colMin5 = min(col0,min(col5,min(col6,min(col7,col8))));

	colMin = 0.5 * (colMin + colMin5);
	colMax = 0.5 * (colMax + colMax5);

  gl_FragData[0].rgb = colMax;
  gl_FragData[1].rgb = colMin;
}
#endif