#ifndef PLANE_CLIP_PASS
#define PLANE_CLIP_PASS

#ifdef OriginalVertOut
	#define PARAMS_COMMA ,
#else
	#define PARAMS_COMMA
#endif

#ifdef CLIP_EXTRA_OUT_1_SEMANTICS
	#define SEMANTICS_POSTFIX_1 : CLIP_EXTRA_OUT_1_SEMANTICS
#endif

#ifdef CLIP_EXTRA_OUT_1
	#define CLIP_EXTRA_OUT_ACTUAL_1 CLIP_EXTRA_OUT_1
	#ifdef CLIP_EXTRA_OUT_2
		#define CLIP_EXTRA_OUT_ACTUAL_2 CLIP_EXTRA_OUT_2
		#ifdef CLIP_EXTRA_OUT_3
			#define CLIP_EXTRA_OUT_ACTUAL_3 CLIP_EXTRA_OUT_3
		#endif
	#else
		#ifdef CLIP_EXTRA_OUT_3
			#define CLIP_EXTRA_OUT_ACTUAL_2 CLIP_EXTRA_OUT_3
		#endif
	#endif
#else
	#ifdef CLIP_EXTRA_OUT_2
		#define CLIP_EXTRA_OUT_ACTUAL_1 CLIP_EXTRA_OUT_2
		#ifdef CLIP_EXTRA_OUT_3
			#define CLIP_EXTRA_OUT_ACTUAL_2 CLIP_EXTRA_OUT_3
		#endif
	#else
		#ifdef CLIP_EXTRA_OUT_3
			#define CLIP_EXTRA_OUT_ACTUAL_1 CLIP_EXTRA_OUT_3
		#endif
	#endif
#endif

#define CLIP_EXTRA_ACTUAL_1_WITH_SEMANTICS CLIP_EXTRA_OUT_ACTUAL_1 o1 SEMANTICS_POSTFIX_1
#define CLIP_EXTRA_ACTUAL_2_WITH_SEMANTICS CLIP_EXTRA_OUT_ACTUAL_2 o2 SEMANTICS_POSTFIX_2
#define CLIP_EXTRA_ACTUAL_3_WITH_SEMANTICS CLIP_EXTRA_OUT_ACTUAL_2 o3 SEMANTICS_POSTFIX_3

#define CLIP_EXTRA_OUT_ACTUAL_1_WITH_SEMANTICS out CLIP_EXTRA_ACTUAL_1_WITH_SEMANTICS
#define CLIP_EXTRA_OUT_ACTUAL_2_WITH_SEMANTICS out CLIP_EXTRA_ACTUAL_2_WITH_SEMANTICS
#define CLIP_EXTRA_OUT_ACTUAL_3_WITH_SEMANTICS out CLIP_EXTRA_ACTUAL_3_WITH_SEMANTICS

// TODO handle extra outputs in fragment shader

#ifdef CLIP_EXTRA_OUT_ACTUAL_1
	#ifdef CLIP_EXTRA_OUT_ACTUAL_2
		#ifdef CLIP_EXTRA_OUT_ACTUAL_3
			#define EXTRA_OUTPUTS \
				, CLIP_EXTRA_OUT_ACTUAL_1_WITH_SEMANTICS \
				, CLIP_EXTRA_OUT_ACTUAL_2_WITH_SEMANTICS \
				, CLIP_EXTRA_OUT_ACTUAL_3_WITH_SEMANTICS

			#define EXTRA_INPUTS \
				PARAMS_COMMA CLIP_EXTRA_ACTUAL_1_WITH_SEMANTICS \
				, CLIP_EXTRA_ACTUAL_2_WITH_SEMANTICS \
				, CLIP_EXTRA_ACTUAL_3_WITH_SEMANTICS

			#define EXTRA_VERT_PARAMS \
					, o1 \
					, o2 \
					, o3

			#define EXTRA_FRAG_PARAMS \
				PARAMS_COMMA \
					  o1 \
					, o2 \
					, o3

		#else // CLIP_EXTRA_OUT_ACTUAL_3
			#define EXTRA_OUTPUTS \
				, CLIP_EXTRA_OUT_ACTUAL_1_WITH_SEMANTICS \
				, CLIP_EXTRA_OUT_ACTUAL_2_WITH_SEMANTICS

			#define EXTRA_INPUTS \
				PARAMS_COMMA CLIP_EXTRA_ACTUAL_1_WITH_SEMANTICS \
				, CLIP_EXTRA_ACTUAL_2_WITH_SEMANTICS

			#define EXTRA_VERT_PARAMS \
					, o1 \
					, o2

			#define EXTRA_FRAG_PARAMS \
				PARAMS_COMMA \
					  o1 \
					, o2
		#endif
	#else // CLIP_EXTRA_OUT_ACTUAL_2
		#define EXTRA_OUTPUTS \
			, CLIP_EXTRA_OUT_ACTUAL_1_WITH_SEMANTICS

		#define EXTRA_INPUTS \
			PARAMS_COMMA CLIP_EXTRA_ACTUAL_1_WITH_SEMANTICS

		#define EXTRA_VERT_PARAMS \
			, o1

		#define EXTRA_FRAG_PARAMS \
			PARAMS_COMMA \
				  o1
	#endif // CLIP_EXTRA_OUT_ACTUAL_2
#else // CLIP_EXTRA_OUT_ACTUAL_1
	#define EXTRA_VERT_PARAMS
	#define EXTRA_FRAG_PARAMS
	#define EXTRA_INPUTS
	#define EXTRA_OUTPUTS
#endif

#if !PLANE_CLIPPING_ENABLED || !ADD_xPOS_WORLD
	#ifdef OriginalVertOut
		OriginalVertOut vertClip (
			VertexInput v
			EXTRA_OUTPUTS
		) { 
			return OriginalVert(
				v
				EXTRA_VERT_PARAMS
			);
		}
	#else
		void vertClip (
			VertexInput v
			EXTRA_OUTPUTS
		) { 
			OriginalVert(
				v
				EXTRA_VERT_PARAMS
			);
		}
	#endif // OriginalVertOut
#endif

#if !PLANE_CLIPPING_ENABLED
	#if !COMPLEX_CLIPPING_FRAG
		half4 fragClip (
			#ifdef OriginalVertOut
				OriginalVertOut i
			#endif
			EXTRA_INPUTS
		) : SV_Target { 
			return OriginalFrag(
				#ifdef OriginalVertOut
					i
				#endif
				EXTRA_FRAG_PARAMS
			);
		}
	#endif
#else // PLANE_CLIPPING_ENABLED
	#if ADD_POS_WORLD
		#ifdef OriginalVertOut
			void vertClip (
				VertexInput v,
				out float3 posWorld : POS_WORLD_SEMANTIC,
				out OriginalVertOut vertOut
				EXTRA_OUTPUTS
			) { 
				posWorld = mul(unity_ObjectToWorld, v.vertex);
			
				vertOut = OriginalVert(
					v
					EXTRA_VERT_PARAMS
				);
			}
		#else
			void vertClip (
				VertexInput v,
				out float3 posWorld : POS_WORLD_SEMANTIC
				EXTRA_OUTPUTS
			) { 
				posWorld = mul(unity_ObjectToWorld, v.vertex);
			
				OriginalVert(
					v
					EXTRA_VERT_PARAMS
				);
			}
		#endif // OriginalVertOut
	#endif // ADD_POS_WORLD

	#if !COMPLEX_CLIPPING_FRAG
		half4 fragClip (
			#if ADD_POS_WORLD
				float3 iPosWorld : POS_WORLD_SEMANTIC
			#endif
			#ifdef OriginalVertOut
				, OriginalVertOut i
				EXTRA_INPUTS
			#else
				, EXTRA_INPUTS
			#endif
			) : SV_Target {
			#if !ADD_POS_WORLD
				#define iPosWorld i.posWorld
			#endif

			PLANE_CLIP(iPosWorld);
			
			return OriginalFrag(
				#ifdef OriginalVertOut
					i
				#endif
				EXTRA_FRAG_PARAMS
			);
		}
	#endif
#endif // PLANE_CLIPPING_ENABLED

#endif // PLANE_CLIP_PASS
