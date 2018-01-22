#ifndef PLANE_CLIPPING_INCLUDED
#define PLANE_CLIPPING_INCLUDED

//Plane clipping definitions. Uses three planes for clipping, but this can be increased if necessary.

#if CLIP_ONE || CLIP_TWO || CLIP_THREE
	//If we have 1, 2 or 3 clipping planes, PLANE_CLIPPING_ENABLED will be defined.
	//This makes it easier to check if this feature is available or not.
	#define PLANE_CLIPPING_ENABLED 1

	float normalDotDirection(half3 planePosition, half3 planeNormal, half3 pointInWorld)
	{
	  //w = vector from plane to point
	  half3 w = pointInWorld - planePosition;
		return dot(planeNormal, w);
	}

	//we will have at least one plane.
	float4 _planePos;
	float4 _planeNorm;

	//at least two planes.
#if (CLIP_TWO || CLIP_THREE)
	float4 _planePos2;
	float4 _planeNorm2;
#endif

//at least three planes.
#if (CLIP_THREE)
	float4 _planePos3;
	float4 _planeNorm3;
#endif

	//discard drawing of a point in the world if it is behind any one of the planes.
	void PlaneClip(float3 posWorld) {
#if CLIP_THREE
	  clip(float3(
		normalDotDirection(_planePos.xyz, _planeNorm.xyz, posWorld),
		normalDotDirection(_planePos2.xyz, _planeNorm2.xyz, posWorld),
		normalDotDirection(_planePos3.xyz, _planeNorm3.xyz, posWorld)
	  ));
#else //CLIP_THREE
#if CLIP_TWO
	  clip(float2(
		normalDotDirection(_planePos.xyz, _planeNorm.xyz, posWorld),
		normalDotDirection(_planePos2.xyz, _planeNorm2.xyz, posWorld)
	  ));
#else //CLIP_TWO
	  clip(normalDotDirection(_planePos.xyz, _planeNorm.xyz, posWorld));
#endif //CLIP_TWO
#endif //CLIP_THREE
	}

//preprocessor macro that will produce an empty block if no clipping planes are used.
#define PLANE_CLIP(posWorld) PlaneClip(posWorld);
    
#else
//empty definition
#define PLANE_CLIP(s)
#endif

#endif // PLANE_CLIPPING_INCLUDED
