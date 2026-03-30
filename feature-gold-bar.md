# Feature Task: Gold Bar 3d object

## 1. Overview
Implement the visual and rendering logic for the "Gold Bar". The Gold Bar is a custom 3D model that spawns in the world, attaches to a player's vehicle upon pickup, features a metallic HLSL shader, and visually rotates smoothly above the carrier's vehicle.

## 2. Asset & Resource Definitions
* **Target Object ID:** `1212` (to be replaced).
* **Model File:** `goldbar.dff`
* **Texture Archive:** `goldbar.txd`
* **Texture Target Name:** `gold_tex_base` (used for shader application).
* **Shader File:** `gold_shader.fx` (HLSL script for specular/metallic shine).

## 3. Client-Side Requirements (Visuals & Engine Setup)
**A. Model Replacement:**
* On resource start, load `goldbar.txd` and `goldbar.dff`.
* Apply them to Object ID `1212` using `engineImportTXD` and `engineReplaceModel`.

**B. Shader Application:**
* Create a lightweight DirectX shader using `dxCreateShader("gold_shader.fx")`. 
* The shader must add basic specular lighting to mimic a metallic gold surface.
* Apply this shader exclusively to the texture name `"gold_tex_base"` using `engineApplyShaderToWorldTexture`.

**C. Smooth Hover Rotation:**
* Listen for a custom event from the server (e.g., `onClientGoldPickedUp`) to identify when a player acquires the gold and store the gold element in a variable.
* Use the `onClientPreRender` event to handle rotation locally (DO NOT use server-side timers for rotation).
* In the render function:
    1. Verify the gold element exists and is attached to a vehicle (`getElementAttachedTo`).
    2. Calculate a consistent rotation increment using the `timeSlice` parameter to ensure frame-rate independence.
    3. Retrieve the current attachment offsets using `getElementAttachedOffsets`.
    4. Apply the new Z-axis rotation back to the element using `setElementAttachedOffsets` while maintaining the X, Y, and Z positional offsets.

## 4. Server-Side Requirements (State & Attachment)

**B. Pickup & Attachment:**
* When the method `markerHit` in the file `ctg.server.gold.lua` is called, create a new event that can be listened to both on server and on client.
* Use `attachElements` to attach the gold bar to the Carrier's vehicle.
* Apply a Z-axis offset of some meters, based on the vehicle data in `vehicle.data.lua`, so the massive 1-2m gold bar hovers clearly above the vehicle roof.
* Make sure the gold bar is attached to the vehicle and not the player.
* Trigger the client event (`onClientGoldPickedUp`) for all players, passing the gold element so their local scripts can begin rendering the rotation.

## 5. Constraints & Best Practices
* Strictly isolate the rotation math to the client side to prevent network flooding and ensure smooth visual interpolation.
* Ensure the Z-rotation math in the pre-render event resets at 360 degrees to prevent integer overflow over long sessions.