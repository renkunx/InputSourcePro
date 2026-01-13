# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Input Source Pro is a macOS utility for automatic input source switching. It's a Swift/Cocoa application using the MVVM architecture with Combine for reactive programming.

## Build & Run Commands

Open `Input Source Pro.xcodeproj` in Xcode:
- `Cmd+B` - Build
- `Cmd+R` - Run
- `Cmd+U` - Run tests

CLI:
```bash
xcodebuild -scheme "Input Source Pro" -configuration Debug build
xcodebuild -scheme "Input Source Pro" -configuration Debug test
```

## Architecture

### MVVM Pattern
- **Models/**: ViewModels containing business logic and state management
  - `PreferencesVM`: Manages app preferences and Core Data persistence
  - `IndicatorVM`: Controls input source indicator and switching logic
  - `ApplicationVM`: Tracks active applications and browser focus
  - `InputSourceVM`: Handles input source management
  - `PermissionsVM`: Manages system permissions
  - `NavigationVM`: Manages app navigation state

- **Controllers/**: Window and menu controllers
  - `IndicatorWindowController`: Controls the on-screen indicator window
  - `PreferencesWindowController`: Controls the preferences/settings window
  - `StatusItemController`: Manages the menu bar status item

- **UI/**: SwiftUI views
- **Persistence/**: Core Data models and storage
- **Utilities/**: Helper classes and extensions
- **Window/**: Window management classes
- **System/**: App initialization and system-level code

### Key Technologies
- **AXSwift** (custom fork): Accessibility API integration for tracking focused elements/windows
- **SnapKit**: Auto Layout DSL
- **RxSwift/RxCocoa**: Reactive programming
- **Combine**: Apple's reactive framework (heavily used in ViewModels)
- **Sparkle**: Auto-updates
- **KeyboardShortcuts**: Shortcut management
- **Alamofire**: Networking

### MainActor Usage
All ViewModels are marked with `@MainActor` - they must run on the main thread.

### Data Persistence
- **Core Data**: Main data store (`Main.xcdatamodeld`)
- **UserDefaults**: Simple preferences
- Custom caching for keyboard configurations

## Coding Conventions

- **Indentation**: 4 spaces
- **Naming**:
  - Types: `UpperCamelCase` (e.g., `IndicatorWindowController`)
  - Files follow type names
  - Extensions use `Type+Feature.swift` pattern (e.g., `IndicatorWindowController+Activation.swift`)
- **Commit messages**: Conventional commits with scopes (e.g., `feat(UI): add indicator toggle`)
- Follow Swift API Design Guidelines

## Core Functionality

1. **Application-based input source switching**: Detects active app and switches input source
2. **Browser-based switching**: Detects browser tabs for website-specific switching (supports Safari, Chrome, Arc, Edge, Vivaldi, Opera, Brave, Firefox, Zen, Dia)
3. **Input source indicator**: On-screen display of current input source
4. **Function key mode switching**: Per-app function key behavior
5. **Punctuation mode**: Force English punctuation per app
6. **Custom shortcuts**: Keyboard shortcuts and single-modifier shortcuts for input source switching

## Browser Extension

The app integrates with browser extensions to detect the current website. The browser extension communicates with the main app for website-based input source rules.

## Permissions

The app requires:
- **Accessibility permissions**: For tracking focused applications and windows
- **Browser extension permissions**: For detecting active website (optional)

## Dependencies

Managed via Swift Package Manager in Xcode. No Package.swift file - dependencies are configured in the Xcode project.
