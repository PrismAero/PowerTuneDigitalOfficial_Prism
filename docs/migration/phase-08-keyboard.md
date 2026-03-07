# Phase 08 - Prism Keyboard Modernization

## Scope

Harden custom keyboard behavior for Qt6 text input controls without changing screen geometry or interaction model.

## Changes Made

- Updated `Prism/Keyboard/PrismKeyboard.qml`:
  - Added `isEditableTarget(item)` guard.
  - `show()` now ignores invalid/non-editable targets.
  - `sendKey()` uses control-native `insert()` when available.
  - `sendBackspace()` uses control-native `remove()` when available.
  - `sendClear()` uses control-native `clear()` when available.

## Validation

- Keyboard logic now supports both direct text replacement fallback and native text edit methods for better control compatibility.
- Existing dock/popout behavior and `1600x720` constraints are unchanged.

## Rollback

- Revert `Prism/Keyboard/PrismKeyboard.qml` to previous implementation.

## Follow-Up

- Add runtime matrix tests across TextField/TextArea/numeric-entry contexts on both macOS host and Yocto target.
