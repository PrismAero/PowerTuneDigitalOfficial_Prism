# RaceDash Signal Handler Deprecation Fix Plan

## Problem

Qt 6 runtime warning:

```
qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/RaceDash.qml:408:9
Parameter "overlayId" is not declared. Injection of parameters into signal
handlers is deprecated. Use JavaScript functions with formal parameters instead.
```

The deprecated pattern is using signal parameters directly in inline handlers
without formally declaring them. Qt 6 expects the `function onSignalName(param)`
syntax instead.

---

## Affected Locations

### File: RaceDash.qml -- `onConfigRequested` handlers (10 occurrences)

The signal `configRequested(string overlayId, string configType)` is defined in
`DraggableOverlay.qml:16`. Each `DraggableOverlay` instance in `RaceDash.qml`
uses the deprecated inline handler pattern, injecting `overlayId` and
`configType` without formal parameter declaration.

| Line | Overlay ID       | Current Code |
|------|------------------|--------------|
| 119  | shiftOverlay     | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 143  | waterTempOverlay | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 200  | oilPressOverlay  | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 268  | statusRow0Overlay| `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 306  | statusRow1Overlay| `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 379  | tachArcOverlay   | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 408  | tachTextOverlay  | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 457  | speedArcOverlay  | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 486  | speedTextOverlay | `onConfigRequested: configPopup.openFor(overlayId, configType)` |
| 525  | bottomBarOverlay | `onConfigRequested: configPopup.openFor(overlayId, configType)` |

### File: OverlayConfigPopup.qml -- `onColorEdited` handlers (2 occurrences)

The signal `colorEdited(string newColor)` is defined in
`StyledColorPicker.qml:11`. Two `StyledColorPicker` instances use the deprecated
inline pattern with injected `newColor`.

| Line | Context         | Current Code |
|------|-----------------|--------------|
| 360  | Arc Color Start | `onColorEdited: popup.arcColorStart = newColor` |
| 376  | Arc Color End   | `onColorEdited: popup.arcColorEnd = newColor` |

### Files with NO issues (already using correct patterns)

- `DraggableOverlay.qml:34` -- Uses correct `function onPositionsReset() {}`
  syntax in its `Connections` block.
- `RaceDash.qml:95` -- Uses correct `function onConfigChanged(overlayId) {}`
  syntax in its `Connections` block.
- `OverlayConfigPopup.qml:212,489` -- Uses correct `onActivated: function(idx)`
  syntax for ComboBox handlers.

---

## Approach Evaluation

### Option A: QML-side fix using `function` syntax (RECOMMENDED)

Change each deprecated inline handler to use a JavaScript function with formal
parameters:

**For `onConfigRequested` (all 10 in RaceDash.qml):**

```qml
// BEFORE (deprecated):
onConfigRequested: configPopup.openFor(overlayId, configType)

// AFTER (Qt 6 correct):
onConfigRequested: function(overlayId, configType) {
    configPopup.openFor(overlayId, configType)
}
```

**For `onColorEdited` (2 in OverlayConfigPopup.qml):**

```qml
// BEFORE (deprecated):
onColorEdited: popup.arcColorStart = newColor

// AFTER (Qt 6 correct):
onColorEdited: function(newColor) { popup.arcColorStart = newColor }
```

### Option B: C++ migration

Move signal routing logic to a C++ class that receives `configRequested` signals
and dispatches popup opening.

---

## Recommendation: Option A (QML-side fix)

**Rationale:**

1. **The logic is pure UI routing.** The `onConfigRequested` handlers do exactly
   one thing: call `configPopup.openFor(id, type)`. This is "user tapped overlay
   X, show config popup for X" -- textbook UI navigation that belongs in QML.
   Moving this to C++ would mean a C++ class that holds a pointer to a QML popup
   and calls a QML function on it, adding indirection with zero benefit.

2. **The fix is mechanical and minimal.** Each handler needs only the addition of
   `function(param1, param2) { ... }` wrapper syntax. No logic changes, no new
   files, no new classes.

3. **C++ would add unnecessary complexity.** A C++ signal router would need to:
   - Be registered as a QML context property or singleton
   - Hold a reference to the popup (or use `findChild`)
   - Forward parameters back to QML anyway
   - This creates coupling between C++ and QML component internals for no gain

4. **Precedent in this codebase.** The existing `Connections` blocks in
   `RaceDash.qml:93-96` and `DraggableOverlay.qml:32-38` already use the
   correct Qt 6 `function onSignalName(param)` pattern. The inline handlers are
   simply the older style that was not yet updated.

5. **Qt 6 documentation explicitly recommends this pattern.** The
   `function(params)` syntax for inline signal handlers is the standard Qt 6
   approach. It keeps UI wiring in QML where it is discoverable alongside the
   component declarations.

**When C++ WOULD be appropriate:** If overlay selection triggered business logic
(data processing, network calls, persistent state changes beyond simple
QSettings), a C++ handler would be warranted. Here, it is purely "show a popup"
-- QML territory.

---

## Implementation Checklist

1. In `RaceDash.qml`, update all 10 `onConfigRequested` handlers from the
   deprecated inline form to `function(overlayId, configType) { ... }` syntax
2. In `OverlayConfigPopup.qml`, update both `onColorEdited` handlers from the
   deprecated inline form to `function(newColor) { ... }` syntax
3. Build and verify no more deprecation warnings at runtime
4. Verify overlay config popup still opens correctly for all overlay types
5. Verify color picker edits still propagate in the config popup
