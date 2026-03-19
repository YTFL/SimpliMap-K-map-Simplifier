# Karnaugh Map Simplifier

## Overview

This is a Flutter application that provides a tool for simplifying boolean expressions using Karnaugh maps. The user can input a boolean expression in Sum of Products (SOP) form, and the application will display the corresponding K-map, the minimized SOP and Product of Sums (POS) expressions, and a list of the prime implicants.

## Features

*   **Boolean Expression Input**: Users can enter a boolean expression in SOP form.
*   **Variable Selection**: Supports 3 and 4-variable K-maps.
*   **Interactive K-Map**: The application displays a K-map that updates in real-time as the user enters their expression.
*   **Minimization**: The application uses the Quine-McCluskey algorithm to find the minimized SOP and POS expressions.
*   **Step-by-Step Breakdown**: The user can see the prime implicants that were found during the minimization process.
*   **SOP and POS Results**: The final minimized expressions are displayed in both SOP and POS forms.
*   **Performance**: The prime implicants are calculated only when the "Solve" button is pressed, improving the application's responsiveness.

## File Structure

*   `lib/main.dart`: The main entry point of the application.
*   `lib/state/kmap_provider.dart`: The state management for the application, using the Provider package.
*   `lib/logic/boolean_parser.dart`: The logic for parsing the user's boolean expression.
*   `lib/logic/minimizer.dart`: The implementation of the Quine-McCluskey algorithm.
*   `lib/models/implicant.dart`: The data model for an implicant.
*   `lib/models/minterm.dart`: The data model for a minterm.
*   `lib/widgets/solver_screen.dart`: The main screen of the application.
*   `lib/widgets/kmap_grid.dart`: The widget for the K-map grid.
*   `lib/widgets/minimization_result.dart`: The widget for displaying the minimization results.
*   `lib/widgets/step_breakdown.dart`: The widget for displaying the prime implicants.
*   `lib/widgets/theme.dart`: The theme data for the application.
*   `lib/widgets/expression_input.dart`: The widget for the expression input field.
*   `lib/widgets/control_panel.dart`: The widget for the control panel.
*   `.idx/dev.nix`: The development environment configuration.

## How to Use

1.  Enter a boolean expression in the input field.
2.  Select the number of variables (3 or 4).
3.  The K-map will update automatically.
4.  Click the "Solve" button to see the minimized expressions and the prime implicants.
