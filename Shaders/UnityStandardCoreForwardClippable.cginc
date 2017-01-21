#ifndef UNITY_STANDARD_CORE_FORWARD_INCLUDED
#define UNITY_STANDARD_CORE_FORWARD_INCLUDED

#if defined(UNITY_NO_FULL_STANDARD_SHADER)
#	define UNITY_STANDARD_SIMPLE 1
#endif

#include "UnityStandardConfig.cginc"

#if UNITY_STANDARD_SIMPLE
	#include "UnityStandardCoreForwardSimple.cginc"
	VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
	VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }
	half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); }
	half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); }
#else
	#include "standard_clipped.cginc"
	VertexOutputForwardClipBase vertBase (VertexInput v) { return vertForwardClipBase(v); }
	VertexOutputForwardClipAdd vertAdd (VertexInput v) { return vertForwardClipAdd(v); }
	half4 fragBase (VertexOutputForwardClipBase i) : SV_Target { return fragForwardClipBaseInternal(i); }
	half4 fragAdd (VertexOutputForwardClipAdd i) : SV_Target { return fragForwardClipAddInternal(i); }
#endif

#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED
