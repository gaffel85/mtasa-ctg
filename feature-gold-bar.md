# Feature Task: Gold Bar 3D Object & Visuals (Refined)

## 1. Overview
Implement the visual and rendering logic for the "Gold Bar". The Gold Bar is a persistent 3D model that spawns in the world, attaches to vehicles upon pickup with vehicle-specific offsets, features a metallic HLSL shader, and rotates smoothly local to each client.

## 2. Asset & Resource Definitions
*   **Target Object ID:** `1212` (Money - chosen for high replacement stability).
*   **Model File:** `goldbar.dff`
*   **Texture Archive:** `goldbar.txd`
*   **Texture Target Name:** `gold_tex_base`
*   **Shader File:** `gold_shader.fx` (HLSL Vertex + Pixel shader).
*   **Scale:** `5.0` (Calculated to achieve approx. 2m width).

## 3. Server-Side Implementation (Attachment & State)
*   **Persistent Element:** A single `activeGoldObject` is maintained per round.
*   **Vehicle-Specific Offsets:** 
    *   Attachment uses `z2` (roof height) from `shared/vehicle.data.lua`.
    *   Calculation: `zOffset = z2 + 0.5`.
*   **Event-Driven Sync:** 
    *   Triggers `onClientSetGoldElement` to inform clients which element is the current Gold Bar.
    *   Handles `onClientRequestGoldElement` for late joiners.
*   **Red Marker Sync:** The red arrow marker also attaches to the vehicle at `zOffset + 4.0` for enhanced visibility.

## 4. Client-Side Implementation (Visuals & Rendering)
*   **Strict Loading Order:** TXD -> DFF -> `engineReplaceModel` -> `engineRestreamWorld`.
*   **Metallic Shader:**
    *   Uses a pixel shader to modulate the base texture with a rich gold tint (`1.0, 0.8, 0.2`).
    *   Includes a "minimum light" floor to prevent the object from turning pure black in the shade.
    *   Applied specifically to the Gold Bar element to avoid affecting other world objects using the same texture name.
*   **Smooth Rotation:**
    *   Handled in `onClientPreRender` using the `timeSlice` parameter.
    *   Updates `setElementAttachedOffsets` when attached to a vehicle and `setElementRotation` when on the ground.

## 5. Best Practices & Findings
*   **ID Stability:** Model `1550` proved more stable for replacement than `1212` in this environment.
*   **Engine Sync:** A 1-second delay between loading and replacement ensures the engine has properly initialized textures before model application.
*   **Element Tracking:** Direct element tracking via custom events is used instead of frame-by-frame `getElementsByType` searches for maximum performance.
