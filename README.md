# ⏱️ Timestop Eye FX (UE5)

Custom HLSL shader built inside a **UE5 Custom Node**, simulating a cyberpunk-inspired time-stop/control iris effect.  
This effect combines emissive: bursts, radial sweeps, and clock-like tally marks.  

🎥 **Video Showcase:** [https://www.youtube.com/watch?v=HdKnlGgKhlA]  

---

## 🔹 Node Details

**Output Type(s):**
- `CMOT Float3` (Main Output)
- `Emissive` (Float3, sent to material emissive channel)

**Additional Output(s):**
- `return` → Float3 (used as main shader return)  
- `Emissive` → Float3 (explicit emissive channel)  

---

## 🔹 Input Parameters

Below is the full list of exposed inputs for the custom node:

1. `UV`  
2. `IrisTex`  
3. `UVScale`  
4. `UVOffset`  
5. `TintColor`  
6. `EyeFXTex`  
7. `EyeFXColor`  
8. `ShowEyeFX`  
9. `FXBurstStrength`  
10. `FXBurstTime`  
11. `FXBurstSharpness`  
12. `FXBurstScale`  
13. `FXBurstBaseFade`  
14. `FXSweepHours`  
15. `FXSweepTex`  
16. `FXSweepHourExponent`  
17. `SweepAfterimageExponent`  
18. `FXSweepEmissiveBoost`  
19. `ShowSweepFX`  
20. `ShowSweepMinFX`  

---

## 🔹 Shader Notes

- Written as inline HLSL inside a UE5 **Material Custom Node**.  
- Final output is assigned to both `return` and `Emissive` pins.  
- Designed for showcase/portfolio purposes — not optimized for production use.
- Some textures were iterated with AI assistance (ChatGPT), and shader development benefited from “rubberducking” through AI-aided brainstorming. All final HLSL code and UE5 implementation are authored and tested by me.

---

## 📂 Files Included
- Shader source code → `Jbonura_TimestopEyeFX.hlsl`
- Textures → `CustomIris1.png`, `RGB_CustomIris1.png`, `2DegRadial.png` 
- Screenshots → Example UE5 Material setup `JBP_TimestopEye_UE5Screenshot.PNG` 

---

👤 **Author:** Joseph Bonura  
