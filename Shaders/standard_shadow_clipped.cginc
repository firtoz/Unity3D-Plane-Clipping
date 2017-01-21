// Modified version of UnityStandardShadow.cginc

#ifndef UNITY_STANDARD_SHADOW_CLIP_INCLUDED
#define UNITY_STANDARD_SHADOW_CLIP_INCLUDED

#include "UnityStandardShadow.cginc"
#include "plane_clipping.cginc"

#ifndef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	#if PLANE_CLIPPING_ENABLED
		#define UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT 1
		#define CLEAR_UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	#endif
#endif

#ifdef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT 

struct VertexOutputShadowCasterClip
{
	V2F_SHADOW_CASTER_NOPOS
#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
	float2 tex : TEXCOORD1;

	#if defined(_PARALLAXMAP)
		half4 tangentToWorldAndParallax[3]: TEXCOORD2;	// [3x3:tangentToWorld | 1x3:viewDirForParallax]

		#if PLANE_CLIPPING_ENABLED
			float3 posWorld : TEXCOORD3;
		#endif
	#else // defined(_PARALLAXMAP)
		#if PLANE_CLIPPING_ENABLED
			float3 posWorld : TEXCOORD2;
		#endif // PLANE_CLIPPING_ENABLED
	#endif // defined(_PARALLAXMAP)
#else // defined(UNITY_STANDARD_USE_SHADOW_UVS)
	#if PLANE_CLIPPING_ENABLED
		float3 posWorld : TEXCOORD1;
	#endif // PLANE_CLIPPING_ENABLED
#endif // defined(UNITY_STANDARD_USE_SHADOW_UVS)
};
#endif

// We have to do these dances of outputting SV_POSITION separately from the vertex shader,
// and inputting VPOS in the pixel shader, since they both map to "POSITION" semantic on
// some platforms, and then things don't go well.


void vertShadowCasterClip (VertexInput v,
	#ifdef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	out VertexOutputShadowCasterClip o,
	#endif
	out float4 opos : SV_POSITION)
{
	UNITY_SETUP_INSTANCE_ID(v);

#if PLANE_CLIPPING_ENABLED
	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.posWorld = posWorld.xyz;
#endif
	TRANSFER_SHADOW_CASTER_NOPOS(o,opos)
	#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
		o.tex = TRANSFORM_TEX(v.uv0, _MainTex);

		#ifdef _PARALLAXMAP
			TANGENT_SPACE_ROTATION;
			half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
			o.tangentToWorldAndParallax[0].w = viewDirForParallax.x;
			o.tangentToWorldAndParallax[1].w = viewDirForParallax.y;
			o.tangentToWorldAndParallax[2].w = viewDirForParallax.z;
		#endif
	#endif
}

half4 fragShadowCasterClip (
	#ifdef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	VertexOutputShadowCasterClip i
	#endif
	#ifdef UNITY_STANDARD_USE_DITHER_MASK
	, UNITY_VPOS_TYPE vpos : VPOS
	#endif
	) : SV_Target
{
	PLANE_CLIP(i.posWorld)

	#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
		#if defined(_PARALLAXMAP) && (SHADER_TARGET >= 30)
			//On d3d9 parallax can also be disabled on the fwd pass when too many	 sampler are used. See EXCEEDS_D3D9_SM3_MAX_SAMPLER_COUNT. Ideally we should account for that here as well.
			half3 viewDirForParallax = normalize( half3(i.tangentToWorldAndParallax[0].w,i.tangentToWorldAndParallax[1].w,i.tangentToWorldAndParallax[2].w) );
			fixed h = tex2D (_ParallaxMap, i.tex.xy).g;
			half2 offset = ParallaxOffset1Step (h, _Parallax, viewDirForParallax);
			i.tex.xy += offset;
        #endif

		half alpha = tex2D(_MainTex, i.tex).a * _Color.a;
		#if defined(_ALPHATEST_ON)
			clip (alpha - _Cutoff);
		#endif
		#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
			#if defined(_ALPHAPREMULTIPLY_ON)
				half outModifiedAlpha;
				PreMultiplyAlpha(half3(0, 0, 0), alpha, SHADOW_ONEMINUSREFLECTIVITY(i.tex), outModifiedAlpha);
				alpha = outModifiedAlpha;
			#endif
			#if defined(UNITY_STANDARD_USE_DITHER_MASK)
				// Use dither mask for alpha blended shadows, based on pixel position xy
				// and alpha level. Our dither texture is 4x4x16.
				half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy*0.25,alpha*0.9375)).a;
				clip (alphaRef - 0.01);
			#else
				clip (alpha - _Cutoff);
			#endif
		#endif
	#endif // #if defined(UNITY_STANDARD_USE_SHADOW_UVS)

	SHADOW_CASTER_FRAGMENT(i)
}

#ifdef CLEAR_UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	#undef CLEAR_UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	#undef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
#endif

#endif // UNITY_STANDARD_SHADOW_CLIP_INCLUDED
