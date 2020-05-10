/*
 *Copyright 2020 Chen Ming
 *Attribution-ShareAlike 4.0 International
 */





#ifndef VolumeSpace_Enabled
#define VolumeSpace_Enabled
/******************************************/

int GetVolumeMapResPlane()
{
	float volumeMapResPlaneF = pow(float(shadowMapResolution), 0.333333333333333);
	return int(volumeMapResPlaneF);
}

int GetVolumeMapResSingle(in int volumeMapResPlane)
{
	return pow2(volumeMapResPlane);
}

#if Format == vert
vec4 GetSingleVolumeMapPlaneVertPos(in vec4 vertPos, in int volumeMapRes, in float volumeMapPlaneRange, in float volumeMapPlaneDepth)
{
	float volumeMapPosCurrector = mod(float(volumeMapRes), 2.0) * 0.25;

	vertPos.xy  = round(vertPos.xy);
	vertPos.xy += volumeMapPosCurrector * 2.0;
	vertPos.z  = round(vertPos.z * volumeMapPlaneDepth) / volumeMapPlaneDepth;
	vertPos.z += volumeMapPosCurrector / volumeMapPlaneDepth;

	vertPos.xyz *= 2.0;
	vertPos.xy /= float(volumeMapRes);


	return vertPos;
}

vec2 GetVolumeMapPlanesVertPos(in vec3 vertPos, in int volumeMapRes, in int volumeMapResPlane, in float availableRange, in float volumeMapPlaneDepth)
{
	float volumeMapPlaneCount = vertPos.z;


	vertPos.xy = fma(vertPos.xy, vec2(0.5), vec2(0.5));

	vertPos = saturate(vertPos);
	//TODO: Fix these!
	vertPos.x += floor(mod(volumeMapPlaneCount, float(volumeMapResPlane)));
	vertPos.y += floor(volumeMapPlaneCount / float(volumeMapResPlane));


	vertPos.xy *= float(volumeMapRes) / float(shadowMapResolution);
	vertPos.xy = clamp(vertPos.xy, 0.0, availableRange);

	vertPos.xy = fma(vertPos.xy, vec2(2.0), vec2(-1.0));


	return vertPos.xy;
}

vec4 GetVolumeMapVertPos(in vec4 vertPos, in vec2 texCoord, in int volumeMapRes, in int volumeMapResPlane)
{
	float volumeMapPlaneRange = float(volumeMapResPlane) / float(shadowMapResolution);
	float availableRange = float(volumeMapRes) * volumeMapPlaneRange;

	float volumeMapPlaneDepth = far - near;
	float volumeMapBlockDepth = volumeMapPlaneDepth / float(volumeMapRes);


	vertPos = GetSingleVolumeMapPlaneVertPos(vertPos, volumeMapRes, volumeMapPlaneRange, volumeMapPlaneDepth);
	vertPos.xy = GetVolumeMapPlanesVertPos(vertPos.xyz, volumeMapRes, volumeMapResPlane, availableRange, volumeMapPlaneDepth);


	return vec4(vertPos.xy, 0.0, 1.0);
}
#elif Format == frag
/* TODO: Make these working!
vec3 GetCamPosInVolumeSpace(in int volumeMapRes, in int volumeMapResPlane)
{
	float volumeMapPosCurrector = mod(float(volumeMapRes), 2.0) * 0.25;
	float volumeMapPlaneRange = float(volumeMapResPlane) / float(shadowMapResolution);
	float availableRange = float(volumeMapRes) * volumeMapPlaneRange;


	vec4 camPosInShadowSpace = shadowModelViewInverse * shadowProjectionInverse * vec4(cameraPosition, 1.0);
	vec3 camPosInVolumeSpace = camPosInShadowSpace.xyz;

	camPosInVolumeSpace.xy += volumeMapPosCurrector * availableRange * 2.0;
	camPosInVolumeSpace.xy *= volumeMapPlaneRange * 2.0;
	camPosInVolumeSpace.z += volumeMapPosCurrector;
	camPosInVolumeSpace.z /= float(volumeMapRes);


	return camPosInVolumeSpace;
}

vec2 GetTexCoordFromVolumeSpace(in vec4 worldPos, in int volumeMapRes, in int volumeMapResPlane)
{
	float volumeMapPosCurrector = mod(float(volumeMapRes), 2.0) * 0.25;
	float volumeMapPlaneRange = float(volumeMapResPlane) / float(shadowMapResolution);
	float availableRange = float(volumeMapRes) * volumeMapPlaneRange;


	vec4 shadowPos = shadowModelViewInverse * shadowProjectionInverse * worldPos;
	vec2 volumePos = shadowPos.xy;

	volumePos += volumeMapPosCurrector * availableRange * 2.0;
	volumePos *= volumeMapPlaneRange * 2.0;


	return textureLod(shadowcolor0, volumePos, 0.0).xy;
}
*/
#endif

/******************************************/
#endif
