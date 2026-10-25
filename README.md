# Vision Ware V1 — Interface directe

One loadstring, one main interface (no access gate), one Lua file per game profile.

## Script

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VisionHub_V1.lua"))()
```

## Design

- Main window inspired by the visual structure of Sena Hub: dark theme, compact settings in **two columns**, search, category sidebar, footer with executor/FPS and responsive layout.
- The sidebar now uses **the user's selected neon VW artwork**, resized for the 38 px icon: [`assets/visionware_logo_exact.png`](assets/visionware_logo_exact.png). The earlier flat logo files remain archived in `assets/` but are no longer used by the loader.


### Interface V1 (October 2026)

- Desktop layout follows the Sena reference's measured geometry: **865 × 548** logical pixels (normal-sized window), **195 px** left rail, **64 px** header, **38 px** footer, **210 × 37 px** search, and balanced two-column cards. These are approximate measurements from the available Sena screenshot, not the original source UI files.
- Spacing and controls match the reference closely: charcoal-on-black cards, 44 px card headings, ~76 px toggle rows, ~78 px dropdown rows, ~88 px slider rows, cyan Vision Ware identity and separated footer status/FPS pills. Layout scales to smaller screens.
- Bottom-right **Executor / FPS / v1.0** badges are now grouped tightly with their widths based on content, following the reference rather than using three oversized pills.
- **UI refinement pass:** balanced charcoal palette, clearer typography, sidebar group label and RightShift hint, cyan active icon/indicator, smoother hover transitions, improved card and control alignment, more readable sliders and action buttons.
- **Search improvements:** dedicated clear control and "Nothing found" feedback when no matching options exist.
- **Status feedback:** important longer messages appear briefly as an unobtrusive toast rather than being cut off in the compact footer.
- Existing window size (**865 × 548**), selected VW neon logo, game modules, and minimal Misc tab remain unchanged.
- Vision Ware opens the main window **immediately** on execution, without an access gate or validation.
- All game-specific profiles and the global **Misc** security tab are preserved.
- The user-facing brand is **VISION WARE**. The GitHub filename `VisionHub_V1.lua` remains unchanged for backward compatibility with the existing loadstring.

## Separate game modules

| File | Auto-selection |
| --- | --- |
| `games/universal.lua` | Loaded for common options in every game |
| `games/misc.lua` | Misc security UI, included in all game profiles |
| `games/tycoon.lua` | Game title contains `tycoon` |
| `games/obby.lua` | Game title contains `obby` or `parkour` |
| `games/mm2.lua` | Murder Mystery 2, PlaceId 142823291 |
| `games/arsenal.lua` | Arsenal, PlaceId 286090429 |
| `games/phantom_forces.lua` | Phantom Forces, PlaceId 292439477 |
| `games/war.lua` | Title contains `war`, `army`, `battle`, or `military` |

The loader uses one canonical main window and fetches `games/universal.lua` plus the detected game file. Each profile **returns a table** of sections and controls. The game-specific profiles currently provide local utilities and game-tailored layouts. Game-specific automation is not included.

The system gracefully falls back to the universal dashboard if the game is unknown or a module fails to load.

## Misc security and server anti-exploit

The **Misc** tab keeps **one card with two optional local protections**. **Anti-Fling** recognizes unusually large horizontal/upward velocity spikes and character rotation, then attempts to damp them; it also includes thresholds based on walk speed and limited notification frequency. **Anti-Void** records a verified stationary ground position after stable contact, validates that the platform still exists and attempts rescue when the character enters a dangerous fall or approaches the destruction boundary. Ground checks are throttled to about 10 Hz and rescue confirmation happens only when necessary. Both reset their internal state on respawn; vehicles, swimming and climbing are excluded to reduce false positives. These client-only techniques can be limited or overridden by the Roblox server and can still react to intentional launch pads or very long legitimate falls.

For experiences you own, the repository also includes:

- [`server/AntiExploit.server.lua`](server/AntiExploit.server.lua) — server-side fly, speed and teleport anomaly checks.
- [`server/CombatGuard.lua`](server/CombatGuard.lua) — server raycast, shot-origin and fire-rate validation with suspicious aim-snap logging.
- [Server installation instructions](server/README.md) — Studio setup, exceptions and example weapon integration.

These **server scripts must be installed in your own Roblox Studio experience**.
They are not installed by the client loadstring. Automatic enforcement is disabled by
default to avoid false positives; aim-assist detection cannot be fully reliable.

## Game module schema

```lua
return {
 id="example",
 name="Example Game",
 description="Short description",
 sections={
   { tab="Game", column="left", title="Section name", subtitle="Optional",
     items={
       { type="info", label="Place", value="@place" },
       { type="toggle", id="fps", label="Show FPS", desc="Overlay" },
       { type="slider", id="fov", label="Camera FOV", min=50, max=110 },
       { type="dropdown", id="fovPreset", label="Preset", values={"Default · 70", "Wide · 90", "Focus · 60"} },
       { type="button", id="copyPlace", label="Copy Place ID" }
     }
   }
 }
}
```

Supported controls use handlers in the main hub. New `id` values require a corresponding handler in the core; adding a display-only control cannot silently implement new game behavior.

## Logo integration

The current logo uses the exact selected original neon artwork, cropped and reduced to a 96 × 96 PNG for the small Roblox sidebar icon. Roblox `ImageLabel.Image` cannot load a raw GitHub URL directly: the loader downloads the PNG with `game:HttpGet`, saves it using `writefile`, and displays it through `getcustomasset` (or `getsynasset`) where these optional functions exist. Its new `visionware_exact_logo_v3.png` cache name avoids showing earlier versions. If those functions are unavailable, a simple native fallback appears instead. The original UI dimensions and Misc options are unchanged.

## Verification notes

The main Lua loader and its eight game/misc modules have passed a source-level structural check (balanced delimiters and expected references). This is **not** a Roblox runtime or full Luau compiler test. To validate the interface, test it in a controlled Roblox experience at both desktop and mobile-sized resolutions. Check the active sidebar, search/clear/no-results, switch and slider state, collapsing cards, RightShift, FPS footer, and image asset support. Some local changes to character/camera can be overridden by server/game settings.
