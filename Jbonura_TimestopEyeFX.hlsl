// User Input List:
//float2 UV - Default Tex Coordinates
//Texture2D IrisTex - BaseColor Eye Iris Texture
//float2 UVScale - Two scaling values to stretch UVs to fit mesh (4,2)
//float2 UVOffset - Two scaling values to shift UV to fit mesh (0,0)
//float3 TintColor - Color that multiplies over Eye texture
//Texture2D EyeFXTex - Texture for timestop FX system. FX elements split by channels (minutes.r, hours.g, hour highlights.b)
//float3 EyeFXColor - Color dictating FX elements
//float ShowEyeFX - (0-1) Multipliy toggle to show any of the FX elements (default = 0)
//float FXBurstStrength - (0-10) Determines strength of FXBurst Emissive (default = 1.5)
//float FXBurstTime - (0-1) Scalar controling animation of FX burst from full off to full on (default = 0)
//float FXBurstSharpness - Scalar modifying cutoff of radial gradient edge in FXBurst system (default = 10)
//float FXBurstScale - Scalar setting distance from center reach of FXBurst radial effect (default = 0.21)
//float FXBurstBaseFade - (1-256) Scales relationship of burst fx mask and burst iris highlishts (default = 64)
//float FXSweepHours - (0-12) Scalar controling animation of FX Sweep. Number aligns with a time on clock face (default = 0)
//Texture2D FXSweepTex - Conic Radial Gradient texture to spin around clock dial FX and act as a mask for sweep system
//float FXSweepHourExponent - Exponent value used to modify EyeFXTex.gb channels to desired emissive "strength" (default = 1.5)
//float SweepAfterimageExponent - Exponent value used to modify FXSweepTex to a desired emissive "strength" (default = 32)
//float FXSweepEmisssiveBoost - Scalar used to increase emissive of final FXSweep system (default = 30)
//float ShowSweepFX - (0-1) Multipliy toggle to show the FXSweep elements (default = 0)
//float ShowSweepMinFX - (0-1) Multipliy toggle to show the minute FXSweep elements (default = 0)

// ---------------------
// Step 0: Function Creation and Definition 
// ---------------------

struct function
{
	//Parameters
	float2 UV;
	float FXSweepHours;
    
    // Rotate UVs atop a given center point with a given angle
	float2 CustomRotator(float2 UVs, float2 RotationCenter, float Angle)
	{
		float theta = Angle * 6.28318548; // Converting 0–1 to radians
		float2 offset = UVs - RotationCenter;
		float cosA = cos(theta);
		float sinA = sin(theta);
    
		float2 rotated = float2(
            dot(offset, float2(cosA, -sinA)),
            dot(offset, float2(sinA, cosA))
        );
    
		return rotated + RotationCenter;
	}
};

function f;

// Defining function input variables 
f.UV = UV;
f.FXSweepHours = FXSweepHours;

// ---------------------
// Step 1: BaseColor Eye Shader 
// ---------------------

// UV scaling — control size and placement of textures
float2 scaledUV = (UV - 0.5f) * UVScale + 0.5f + UVOffset;

// Sample and tint the base iris texture
float3 iris = Texture2DSample(IrisTex, Material.Texture2D_0Sampler, scaledUV);
float3 irisTinted = iris * TintColor;

// ---------------------
// Step 2: Timestop Eye FX Shader 
// ---------------------

// Sample timestop FX texture and combine r/g channels as base dial mask
float3 eyeFX = Texture2DSample(EyeFXTex, Material.Texture2D_1Sampler, scaledUV);
float eyeFXBaseMask = saturate(eyeFX.r + eyeFX.g);
float3 eyeFXBase = eyeFXBaseMask.xxx * EyeFXColor;

// Define the rotation relationship between hour and minute rotator
float hourSweep = FXSweepHours / -12.0f;
float minuteSweep = FXSweepHours * -1.0f;

// Rotate the UVs of the hour and minute sweep textures off of scaled timers
float2 rotatedHourSweep = f.CustomRotator(scaledUV, float2(0.5f, 0.5f), hourSweep);
float2 rotatedMinuteSweep = f.CustomRotator(scaledUV, float2(0.5f, 0.5f), minuteSweep);

// Splitting iris tex into minute/hour/higlight elements to independently control and mask with radial sweep
float minuteFXSample = eyeFX.r;
float hourFXSample = saturate(eyeFX.g + eyeFX.b);

// User controlled scalar to hour tally visuals from texture
float hourFXSampleBoosted = saturate(pow(hourFXSample, FXSweepHourExponent));

// Setting mask as full rgb coverage for swqqp texture
float3 minuteFXSweep = minuteFXSample.xxx;
float3 hourFXSweep = hourFXSampleBoosted.xxx;

// Sampling sweep radial gradients that will rotate through tally mark masks to simulate clock movement 
float minuteFXRadialSample = Texture2DSample(FXSweepTex, Material.Texture2D_2Sampler, rotatedMinuteSweep).r;
float hourFXSRadialSample = Texture2DSample(FXSweepTex, Material.Texture2D_2Sampler, rotatedHourSweep).r;

// Masking the separated tally marks against a modified radial gradient 
float3 minuteFXRadialmasked = minuteFXSweep * saturate(pow(minuteFXRadialSample, SweepAfterimageExponent));
float3 hourFXRadialmasked = hourFXSweep * saturate(pow(hourFXSRadialSample, SweepAfterimageExponent));

// Combine and boost SweepFX systems into one user controlled variable
float3 FXSweeper = (minuteFXRadialmasked * ShowSweepMinFX) + hourFXRadialmasked;
float3 FXSweepBoost = EyeFXColor * FXSweepEmissiveBoost;
float3 FXSweepFinal = FXSweeper * FXSweepBoost * ShowSweepFX;

// ---------------------
// Step 3: Burst FX Shader
// ---------------------

// Distance from UV to center (0 = center, up to ~0.707 at corners)
float burstDist = distance(scaledUV, float2(0.5f, 0.5f));

// Clamp FXBurstTime to [0, 1]
float burstTime = saturate(FXBurstTime);

// How far outward the burst is currently scaled
float burstEdge = burstTime * FXBurstScale;

// Prevent divide-by-zero by clamping sharpness
float softness = 1.0 / max(FXBurstSharpness, 0.001f);

// Calculate burst mask (1 = full effect at center, fades to 0 at edge)
float burstMaskBase = smoothstep(burstEdge, burstEdge - softness, burstDist);
float burstMaskTally = smoothstep(burstEdge, burstEdge - softness, burstDist) * pow(eyeFX.b, 1.5f);
float burstMaskFinal = saturate((burstMaskBase / max(FXBurstBaseFade, 0.001f)) + burstMaskTally);

// Color burst modulated by burst mask
float3 fxBurst = (EyeFXColor * burstMaskFinal * FXBurstStrength) * irisTinted;

// ---------------------
// Step 4: Combine FX Systems
// ---------------------

float3 eyeFXFinal = (eyeFXBase + fxBurst + FXSweepFinal) * ShowEyeFX;

// ---------------------
// Step 4: Write to Named Outputs
// ---------------------

Emissive = eyeFXFinal;
return irisTinted;