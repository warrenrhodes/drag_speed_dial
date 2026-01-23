## [1.2.0] - 2026-01-23

### Fixed
- **Controller Singleton Pattern**: Removed singleton pattern to allow proper state updates on widget rebuild
- **Screen Snapping Logic**: Fixed `snagOnScreen` feature - now correctly stays in place when enabled, snaps to edges when disabled
- **Vertical Alignment**: Fixed children positioning to correctly appear above or below FAB based on screen location
- **Assertion Logic**: Updated to allow either `actionOnPress` or `dragSpeedDialChildren` (or both)
- **Mutual Exclusion**: Added assertion to prevent both `actionOnPress` and `dragSpeedDialChildren` from being used together

### Removed
- **Tooltip Feature**: Removed tooltip functionality due to complexity and positioning issues
- **Dependencies**: Removed `widget_tooltip` package dependency

### Improved
- **Documentation**: Comprehensive README with multiple usage examples, API reference, and troubleshooting guide
- **Code Quality**: Better state management and more reliable positioning logic

## [1.0.0] - 2024-09-12

- Fix the exception when we press the button.

## [0.0.4] - 2024-05-13

- Fix infinite animation.

## [0.0.3] - 2024-05-20

- Remove the Just_tool_tip.

## [0.0.2] - 2024-05-19

- Update the Readme.md

## [0.0.1] - 2024-05-19

- Initial release
