# UI Specification: "Reactor Core" Dual-Resource HUD

## 1. General Overview
This HUD element is a speedometer-style dual-gauge system designed to track two linked resources: Primary Energy (movement abilities) and Overcharge (ultimate ability). The system uses concentric, non-full circular arcs with a dynamic mechanical transfer system and contextual keybind indicators.

## 2. Positioning and Container
* **Component:** `dgsCreateImage` or an invisible `dgsCreateWindow` (no title bar, no frame).
* **Anchor:** Bottom-right corner of the screen.
* **Offset:** Leave sufficient margin (approx. 20-30 pixels) from the screen edges so it doesn't clip with the native GTA:SA minimap.
* **Size:** Roughly 15% to 20% of the screen height to ensure visibility without blocking gameplay. 

## 3. Layer 1: The Inner Arc (Primary Energy)
* **Function:** Displays the standard renewable energy used for Jump and Nitro.
* **Visuals:**
  * **Color:** Electric Cyan (e.g., HEX `#00FFFF`).
  * **Shape:** A thick circular arc acting as a progress bar. Fixed to a start angle of 135 degrees (bottom-left) and an end angle of 45 degrees (top-right). Fills clockwise.
  * **Background:** A semi-transparent, dark blue/gray track (Alpha ~100) showing the maximum capacity of the arc.
* **Behavior:** Drains smoothly when `[L-SHIFT]` or `[SPACE]` is used. Fills gradually over time or through in-game actions.

## 4. Layer 2: The Outer Arc (Overcharge)
* **Function:** Displays the ultimate resource.
* **Visuals:**
  * **Color:** Amber/Warning Orange (e.g., HEX `#FFBF00`).
  * **Shape:** A thinner circular arc wrapping the outside of the cyan ring. Fixed to the same start (135°) and end (45°) angles.
  * **Background:** A dark, semi-transparent track.
* **Behavior:** Fills *only* when the Inner Arc is actively draining from ability usage.

## 5. Layer 3: The Transfer Valve (Vent Mechanism)
* **Function:** A visual conduit connecting the start of the inner and outer arcs to represent energy conversion.
* **Visuals:** A small half-circle element placed precisely at the 135-degree starting point of both main arcs, bridging them. Acts as its own distinct progress bar.
* **Behavior (The Transfer Sequence):** 1. **Open:** When Nitro/Jump is activated, the valve's internal progress bar fills very rapidly (e.g., 0.25s) to 100%, indicating it has opened.
  2. **Flow:** While the valve remains full/open, the Inner Arc drains and the Outer Arc simultaneously fills.
  3. **Close:** When the ability ceases, the valve's progress bar rapidly drains back to 0%, shutting the connection.

## 6. Layer 4: Ability Keybinds & Status Indicators
* **Function:** Displays available abilities and their dynamic states.
* **Center Layout (Primary Abilities):**
  * Displayed inside the empty center of the arcs.
  * **Top Item:** Text `[L-SHIFT] Nitro`. Color: Electric Cyan.
  * **Middle Item:** Text `[SPACE] Jump`. Color: Electric Cyan.
  * **Dynamic State:** If Inner Arc value < required ability cost, set alpha of these labels to dim them (~100 alpha).
* **Terminal Layout (Ultimate Ability):**
  * **Position:** Placed functionally at the "end" of the Outer Arc (near the 45-degree mark).
  * **Visuals:** Text `[ E ] Shockwave` housed within a distinct "button" background. The button's base background matches the dark, semi-transparent track color of the Outer Arc.
  * **Dynamic State:** When the Outer Arc (Overcharge) hits 100%, the button's background fills with solid Amber (matching the active progress bar), seamlessly blending with the end of the full gauge. The text may invert to black for high contrast, signifying the ultimate power is active and ready to fire.