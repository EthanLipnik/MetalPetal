# Repository Guidelines

## Project Structure & Module Organization
MetalPetal’s core Swift code sits in `Sources/MetalPetal`, while legacy and bridging Objective-C pieces live in `Sources/MetalPetalObjectiveC`. Shared fixtures, helpers, and XCTest targets are in `Tests/MetalPetalTests` and `Tests/MetalPetalTestHelpers`. Platform showcase apps reside in `MetalPetalExamples` (managed through `MetalPetalExamples.xcworkspace`). Generator utilities and automation scripts are collected under `Utilities/` with entry points wired into `test.sh`.

## Build, Test, and Development Commands
Use `swift build` to compile the Swift Package against the default macOS toolchain. Run `swift test` for the standard XCTest suite. Execute `./test.sh` before publishing to regenerate boilerplate, umbrella headers, and package manifests, and to smoke-test macOS, iOS Simulator, tvOS Simulator, and Catalyst builds. For IDE workflows, open `MetalPetalExamples.xcworkspace` in Xcode and run `xcodebuild -workspace MetalPetalExamples.xcworkspace -scheme MetalPetal -destination 'platform=iOS Simulator,name=iPhone 11'` to mirror CI.

## Coding Style & Naming Conventions
Follow the existing Swift 6.2 style: four-space indentation, `CamelCase` types, and `lowerCamelCase` methods or properties. Favor extensions over standalone utilities when adding platform-specific helpers. Keep Objective-C symbols prefixed with `MTI` to match current headers. Run Xcode’s “Format” or `swift format` with default settings before submitting; avoid introducing trailing whitespace or mixed tabs.

## Testing Guidelines
All unit and integration tests use XCTest. Name new files with the feature plus `Tests` suffix (e.g., `MyFilterTests.swift`) and place shared mocks in `Tests/MetalPetalTestHelpers`. Ensure GPU-dependent paths are guarded with `XCTSkip` when Metal devices are unavailable. New filters should include golden-image or numerical assertions to avoid regressions in color math. Aim to keep the `swift test` suite green and fast (<3 minutes locally).

## Commit & Pull Request Guidelines
Model commits on the existing history: imperative, present-tense subjects under 72 characters (e.g., `Add SwiftUI bridge for MTIImageView`). Reference issues in the body when applicable and group related changes per commit. Pull requests should summarize behavioral changes, list test coverage (including `./test.sh` runs if applicable), and attach screenshots or sample renders for UI-visible tweaks. Request review from a maintainer familiar with the affected module and wait for CI to finish before merging.

## Utilities & Code Generation
Whenever you touch shader catalogs, umbrella headers, or package manifests, rerun `./test.sh` or invoke `swift run --package-path Utilities main <tool> <repo-root>` to keep generated files synchronized. Never hand-edit generated Metal headers; instead adjust the source templates in `Utilities/Templates` and regenerate.
