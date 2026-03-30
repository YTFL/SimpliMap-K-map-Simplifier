# SimpliMap - Karnaugh Map Solver

*Interactive Boolean Simplification for Learning and Practice*

## Abstract
SimpliMap is a Flutter-based educational application for teaching and learning Boolean expression minimization using Karnaugh maps (K-maps). It addresses a common gap in digital logic education where students understand basic rules but struggle with practical map cases involving multiple groups, overlaps, and don't-care conditions. To reduce this barrier, SimpliMap combines interactive visualization with algorithmic solving, guiding users from input to minimized output.

The system accepts symbolic Boolean expressions and minterm notation, then maps data into 3-variable or 4-variable K-map layouts for interaction and analysis. Users can edit map cells, run automated solving, and review minimized expressions in both Sum of Products (SOP) and Product of Sums (POS) forms. Internally, the minimization workflow uses Quine-McCluskey-inspired grouping and reduction with prime implicant and essential implicant identification, while the interface provides visual groups and step breakdowns to support understanding.

From a software engineering perspective, SimpliMap follows a modular Flutter architecture with presentation, state management, logic, and model layers. This structure improves maintainability and extension. The implementation delivers reliable core functionality for supported variable sizes across Android and web. This report covers motivation, literature context, architecture, module design, implementation, testing, and evaluation, then concludes with limitations and future enhancements.

## 1. Introduction

### 1.1 Background
Boolean minimization is a fundamental topic in digital logic design and computer engineering. Karnaugh maps are widely used to simplify logical expressions by identifying adjacent groups of minterms. Traditional manual K-map solving can be error-prone, especially when handling multiple grouping choices and don't-care conditions. SimpliMap was developed to provide an interactive and reliable platform for practicing and validating K-map minimization.

### 1.2 Problem Statement
Many students struggle to move from theoretical K-map rules to practical minimization. Existing calculators often provide final answers without transparent intermediate reasoning. There is a need for an application that combines accurate minimization, visual group representation, and explanatory steps in a unified workflow.

### 1.3 Objectives
1. Build a cross-platform Flutter application for K-map solving.
2. Support flexible input formats, including symbolic terms and minterm notation.
3. Generate minimized SOP and POS expressions using a deterministic algorithm.
4. Provide visual grouping and stepwise explanations to improve conceptual understanding.
5. Maintain modular architecture for maintainability and extension.

### 1.4 Scope
The current scope includes 3-variable and 4-variable K-maps, manual cell-state editing, automatic minimization, and explanatory output. The scope excludes higher-order variable minimization (5+ variables), collaborative features, and cloud synchronization.

## 2. Literature Review

### 2.1 Karnaugh Map as a Teaching Method
Karnaugh map methods are a standard simplification approach in introductory digital systems curricula because they convert symbolic Boolean expressions into a visual arrangement that highlights adjacency relationships between minterms. This visual representation helps learners detect grouping opportunities that may be difficult to identify directly from algebraic expressions, especially when multiple variables are involved. In classroom practice, K-maps are valued not only for deriving minimized expressions but also for strengthening conceptual understanding of redundancy elimination, logical equivalence, and design optimization in combinational circuits.

### 2.2 Algorithmic Minimization Approaches
For algorithmic minimization, Quine-McCluskey provides a tabular and systematic method to derive prime implicants, identify essential implicants, and determine reduced logical forms in a repeatable manner. Unlike manual K-map grouping, which can vary depending on user interpretation and grouping order, tabular minimization applies explicit combination rules and coverage checks that reduce ambiguity. As a result, it is frequently referenced in academic and engineering contexts where traceability, consistency, and deterministic output are required, particularly when validating manual solutions or implementing software-based simplification tools.

### 2.3 Relevance to SimpliMap
SimpliMap adopts a practical hybrid strategy in which binary grouping and iterative combination logic inspired by Quine-McCluskey are integrated with direct K-map interaction and visualization. This design choice allows the application to preserve computational correctness while remaining accessible to students who benefit from visual learning and guided reasoning. By combining algorithmic reduction, visual group highlighting, and stepwise explanation output, the tool aligns established minimization theory with a user-centered educational workflow, thereby improving both result reliability and interpretability.

## 3. System Design & Architecture

### 3.1 Application Architecture
SimpliMap follows a layered Flutter architecture:
1. Presentation Layer: screens and widgets for user input, K-map interaction, and result display.
2. State Layer: provider-based state management controlling input parsing, grid updates, and result publication.
3. Logic Layer: Boolean parsing, implicant generation, and expression minimization.
4. Model Layer: domain entities representing implicants, groups, and map terms.

### 3.2 Data Flow and Processing Pipeline
SimpliMap follows a clear end-to-end processing pipeline from user interaction to minimized output generation. First, the user provides input either through symbolic expression text or direct K-map cell editing. The provider layer then validates and normalizes this input before forwarding it to parsing and minimization logic. Parsed terms are transformed into internal representations that support implicant grouping, coverage analysis, and simplified expression construction.

After computation, the resulting SOP/POS expressions, implicant groups, and explanation steps are published back through the state layer to the presentation layer. This unidirectional flow keeps the UI synchronized with solver state and helps prevent inconsistency between visible K-map groups and textual results. The same pipeline also supports reset and recomputation actions, ensuring predictable behavior during repeated learning and experimentation.

### 3.3 Technology Stack
| Category | Technology | Purpose |
| --- | --- | --- |
| Framework | Flutter | Cross-platform UI development for Android and web |
| Language | Dart | Primary programming language for application logic and UI |
| State Management | provider | Reactive state handling between solver logic and interface |
| UI Utilities | google_fonts | Typography customization for improved readability |
| Build Targets | Android, Web | Multi-platform deployment from a single codebase |

## 4. Module Description

### 4.1 Expression Module
This module handles Boolean expression input in symbolic form and minterm notation. It validates user input and forwards valid expressions to the parsing and solving pipeline.

### 4.2 Don't Care Module
This module manages don't-care conditions in both expression-based and table-based workflows. It ensures that don't-care terms are included in grouping logic without forcing them into final required output terms.

### 4.3 Number of Variables Module
This module controls variable selection and map size configuration (3-variable or 4-variable mode). It updates internal dimensions and UI layout based on the chosen variable count.

### 4.4 K-map Table Module
This module renders the interactive K-map grid and supports cell state changes through user actions. It visually represents map values and grouping regions used during minimization.

### 4.5 Minimized Expressions Module
This module generates and displays final simplified expressions in SOP and POS forms. It presents clean output formatting for easy interpretation and verification.

### 4.6 Prime Implicants Module
This module identifies prime implicants and essential prime implicants from grouped terms. It supports coverage analysis used to construct the minimized result.

### 4.7 Solution Explanation Module
This module provides step-by-step explanation of the solving process, including grouping, implicant selection, and final expression derivation. It is intended to improve conceptual understanding for learners.

## 5. Implementation

### 5.1 Development Environment
1. Operating Environment: Windows development workstation.
2. SDK/Toolchain: Flutter stable channel with Dart SDK.
3. IDE: Visual Studio Code.
4. Dependency Management: pub through pubspec.yaml.

### 5.2 Build & Deployment Pipeline
1. Dependency resolution: flutter pub get
2. Local run: flutter run
3. Web build: flutter build web
4. Android release build: flutter build apk --release
The pipeline remains straightforward and reproducible for academic submission scenarios.

### 5.3 Android Packaging
Android configuration resides under the android directory with Gradle Kotlin DSL files. Release packaging is generated via Flutter's build command, producing a signed or unsigned APK depending on keystore setup. The app module and Gradle wrapper files provide compatibility for standard Android toolchains.

## 6. Testing & Validation

### 6.1 Functional Testing
Validation was primarily conducted through functional manual testing of the main solver flow. This included verifying correct simplification for known K-map test cases and checking consistency between visual groupings and computed equations.

### 6.2 Edge Case Validation
Edge cases were tested to confirm solver stability and correctness, including all-zero maps, all-one maps, and configurations with don't-care conditions. These checks were used to ensure reliable behavior across common boundary scenarios.

### 6.3 Interface and Future Test Plan
User interface behavior was validated through interaction testing, such as cell-state cycling and reset actions. For future improvements, the project should include automated unit tests for parsing and minimization logic, along with widget tests to verify UI behavior and output consistency.

## 7. Results & Discussion

### 7.1 Results
The implemented system successfully computes minimized SOP/POS outputs for supported variable sizes and provides user-friendly explanatory feedback. Functional testing confirmed correct behavior for common input patterns, edge conditions, and interactive K-map operations. The application also maintained consistent alignment between visual grouping output and final minimized expressions.

### 7.2 Discussion
The provider-based architecture keeps UI updates responsive and predictable during repeated solving operations. The modular decomposition of parser, solver, state manager, and widgets improves maintainability and enables targeted upgrades. Current limitations remain scope-related, particularly the variable-count ceiling and absence of an automated test suite, which should be addressed in future iterations.

## 8. Conclusion & Future Work

### 8.1 Conclusion
SimpliMap demonstrates how algorithmic minimization and educational visualization can be integrated in a single Flutter application. The project meets its core objectives: correct minimization within supported scope, interactive K-map editing, and transparent explanation of solver steps.

### 8.2 Future Work
Future work should focus on:
1. Support for 5+ variable minimization with scalable heuristics.
2. Automated testing and continuous integration.
3. Export options for reports and worked solutions.
4. Enhanced UX features such as history, undo/redo, and richer validation prompts.

## References
1. M. Morris Mano and M. D. Ciletti, Digital Design, 5th ed., Pearson.
2. S. Brown and Z. Vranesic, Fundamentals of Digital Logic with Verilog Design, McGraw-Hill.
3. Flutter Documentation, https://docs.flutter.dev/
4. Quine, W. V., The Problem of Simplifying Truth Functions, The American Mathematical Monthly.
5. McCluskey, E. J., Minimization of Boolean Functions, Bell System Technical Journal.

## Appendix

### A.1 Project Configuration
| Configuration Area | File/Path | Purpose |
| --- | --- | --- |
| Flutter package metadata and dependencies | pubspec.yaml | Defines app name, version, SDK constraints, and dependencies |
| Static analysis settings | analysis_options.yaml | Configures lint and analyzer behavior for Dart code quality |
| Android project-level build settings | android/build.gradle.kts | Defines shared Gradle configuration for Android build |
| Android app module build settings | android/app/build.gradle.kts | Defines Android app module compile and packaging options |
| Android Gradle properties | android/gradle.properties | Stores Gradle performance and Android build properties |
| Android local SDK properties | android/local.properties | Stores local machine Android SDK path and local settings |
| Android Gradle settings | android/settings.gradle.kts | Registers Gradle plugins and included modules |
| Web app entry HTML | web/index.html | Defines base HTML container for Flutter web app |
| Web app manifest | web/manifest.json | Provides PWA metadata for web installation |

### A.2 Build Scripts and Commands
| Script/Command | Location | Use Case |
| --- | --- | --- |
| flutter pub get | Project root | Resolves and installs Flutter/Dart dependencies |
| flutter run | Project root | Runs the app in debug mode on emulator/device/browser |
| flutter build apk --release | Project root | Builds Android release APK |
| flutter build web | Project root | Builds production-ready web artifacts |
| gradlew | android/gradlew | Executes Gradle tasks on Unix-like systems |
| gradlew.bat | android/gradlew.bat | Executes Gradle tasks on Windows systems |

### A.3 Folder Structure Summary
| Folder | Description | Key Contents |
| --- | --- | --- |
| lib/ | Main application source code | main.dart, logic/, models/, screens/, state/, widgets/ |
| lib/logic/ | Business and minimization logic | boolean_logic.dart, boolean_parser.dart, minimizer.dart |
| lib/models/ | Domain data models | implicant.dart, kmap_group.dart, minterm.dart |
| lib/screens/ | Main app screens | solver_screen.dart |
| lib/state/ | State management layer | kmap_provider.dart |
| lib/widgets/ | Reusable UI components | kmap_grid.dart, minimization_result.dart, step_explanation.dart |
| android/ | Android platform project | app/, build.gradle.kts, gradlew, settings.gradle.kts |
| web/ | Web platform assets | index.html, manifest.json, icons/ |
| build/ | Generated build output | android and Flutter generated artifacts |
| screenshots/ | Project documentation images | UI screenshots used in reports/README |
