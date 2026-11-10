# Graph Report - mako  (2026-11-10)

## Corpus Check
- 234 files · ~13,515 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 52 file(s) not represented in the graph (top: .xcconfig 8, (none) 7, .xml 7)

## Summary
- 677 nodes · 578 edges · 218 communities (26 shown, 192 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 17 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `014262ac`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- win32_window.cpp
- GeneratedPluginRegistrant.swift
- dependencies
- main.dart
- my_application.cc
- FlutterWindow
- app_constants.dart
- utils.cpp
- profile_model.dart
- storage_constants.dart
- StatelessWidget
- Animal Discovery
- 4. Core Features
- manifest.json
- app_providers.dart
- image_utils.dart
- analysis_options.yaml
- validators.dart
- 10. Non-Functional Requirements
- DiscoveryShell
- widget_test.dart
- 1. Product Overview
- 6. User Flow
- 7. Technical Requirements
- 8. Database Requirements
- MainActivity.kt
- 11. MVP Scope
- 3. Target Users
- mako
- AGENTS.md
- LaunchImage.imageset/README.md
- identify-animal/index.ts
- AppDelegate

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `dependencies` - 20 edges
3. `Animal Discovery` - 17 edges
4. `4. Core Features` - 11 edges
5. `FlutterWindow` - 10 edges
6. `WindowClassRegistrar` - 9 edges
7. `_MyApplication` - 7 edges
8. `dev_dependencies` - 7 edges
9. `Size` - 5 edges
10. `Point` - 5 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `FlutterWindow` --inherits--> `Win32Window`  [EXTRACTED]
  windows/runner/flutter_window.h → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `wWinMain()` --calls--> `GetCommandLineArguments()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp

## Import Cycles
- None detected.

## Communities (218 total, 192 thin omitted)

### Community 0 - "win32_window.cpp"
Cohesion: 0.07
Nodes (19): EnableFullDpiSupportIfAvailable(), EnableNonClientDpiScaling, Point, x, y, Scale(), Size, height (+11 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.07
Nodes (18): app_links, Cocoa, file_selector_macos, Flutter, flutter_image_compress_macos, FlutterMacOS, Foundation, SceneDelegate (+10 more)

### Community 2 - "dependencies"
Cohesion: 0.05
Nodes (38): dependencies, cached_network_image, camera, cupertino_icons, flutter, flutter_dotenv, flutter_image_compress, flutter_riverpod (+30 more)

### Community 3 - "main.dart"
Cohesion: 0.03
Nodes (54): backendEnabled, build, _busy, candidate, _candidates, child, _collectionError, color (+46 more)

### Community 4 - "my_application.cc"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 5 - "FlutterWindow"
Cohesion: 0.08
Nodes (5): RegisterPlugins(), FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 6 - "app_constants.dart"
Cohesion: 0.13
Nodes (13): AppConstants, appName, appVersion, defaultPageSize, keyAccessToken, keyIsFirstTime, keyRefreshToken, keyUserLanguage (+5 more)

### Community 7 - "utils.cpp"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 8 - "profile_model.dart"
Cohesion: 0.09
Nodes (19): DateTimeExtension, isPast, isToday, toDateTime, toDayMonth, toFullDate, toMonthYear, toRelativeDeadline (+11 more)

### Community 9 - "storage_constants.dart"
Cohesion: 0.07
Nodes (24): animalPhotosBucket, ApiConstants, calculateStreakFunction, confirmIdentificationFunction, connectTimeout, generateShareCardFunction, getSpeciesDetailFunction, identifyAnimalFunction (+16 more)

### Community 10 - "StatelessWidget"
Cohesion: 0.11
Nodes (17): _Achievement, _AchievementsPage, AnimalDiscoveryApp, _AuthGate, _Button, _CandidateCard, _CollectionPage, _DiscoveryPage (+9 more)

### Community 11 - "Animal Discovery"
Cohesion: 0.17
Nodes (11): 12. Acceptance Criteria, 13. Development Roadmap, 14. Risks & Mitigation, 15. Product Principles, 16. Future Vision, 2.1 Success Metrics, 2. Product Goals, 5. Application Navigation (+3 more)

### Community 12 - "4. Core Features"
Cohesion: 0.18
Nodes (11): 4.10 Profile, 4.1 Authentication, 4.2 Animal Identification, 4.3 Species Details, 4.4 Personal Collection, 4.5 Daily Activity & Streak, 4.6 Achievement System, 4.7 Sharing (+3 more)

### Community 13 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 14 - "app_providers.dart"
Cohesion: 0.22
Nodes (4): authStateProvider, currentUserProvider, supabase, supabaseProvider

### Community 15 - "image_utils.dart"
Cohesion: 0.25
Nodes (4): compressImage, ImageUtils, _picker, pickImage

### Community 16 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 17 - "validators.dart"
Cohesion: 0.40
Nodes (4): validateEmail, validatePassword, validateRequired, Validators

### Community 18 - "10. Non-Functional Requirements"
Cohesion: 0.40
Nodes (5): 10. Non-Functional Requirements, Performance, Reliability, Scalability, Usability

### Community 19 - "DiscoveryShell"
Cohesion: 0.40
Nodes (4): _AuthPage, _AuthPageState, DiscoveryShell, _DiscoveryShellState

### Community 21 - "1. Product Overview"
Cohesion: 0.50
Nodes (4): 1.1 Deskripsi Produk, 1.2 Problem Statement, 1.3 Product Vision, 1. Product Overview

### Community 22 - "6. User Flow"
Cohesion: 0.50
Nodes (4): 6.1 First-Time User Flow, 6.2 Identification Flow, 6.3 Collection Flow, 6. User Flow

### Community 23 - "7. Technical Requirements"
Cohesion: 0.50
Nodes (4): 7.1 Technology Stack, 7.2 Architecture, 7.3 Project Structure, 7. Technical Requirements

### Community 24 - "8. Database Requirements"
Cohesion: 0.50
Nodes (4): 8.1 Core Tables, 8.2 Entity Relationships, 8.3 Database Rules, 8. Database Requirements

### Community 26 - "11. MVP Scope"
Cohesion: 0.67
Nodes (3): 11. MVP Scope, Included in MVP, Post-MVP

### Community 27 - "3. Target Users"
Cohesion: 0.67
Nodes (3): 3.1 Primary Users, 3.2 User Needs, 3. Target Users

## Knowledge Gaps
- **143 isolated node(s):** `_ink`, `_paper`, `_muted`, `supabaseReady`, `_formKey` (+138 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 508 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **192 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `win32_window.cpp` to `FlutterWindow`, `utils.cpp`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `_ink`, `_paper`, `_muted` to the rest of the system?**
  _143 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `win32_window.cpp` be split into smaller, more focused modules?**
  _Cohesion score 0.0693815987933635 - nodes in this community are weakly interconnected._
- **Why does `FlutterWindow` connect `FlutterWindow` to `win32_window.cpp`, `utils.cpp`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.07459677419354839 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Should `main.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02702702702702703 - nodes in this community are weakly interconnected._