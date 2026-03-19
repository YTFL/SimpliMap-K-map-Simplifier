{ pkgs, ... }:
{
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages.
  packages = [
    pkgs.flutter
  ];

  # Sets environment variables in the workspace.
  env = {};

  # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id" for the name.
  extensions = [
    "dart-code.dart-code",
    "dart-code.flutter"
  ];

  # Absolute path to a file to open when the workspace starts.
  # startup.openFile = "/path/to/your/file";

  # Run commands when the workspace starts.
  startup.run = [
    {
      # Add a command to be run in the terminal.
      # The "id" field is used to identify the command in the dev environment.
      # The "name" field is displayed in the UI.
      # The "command" field is the command to be run.
      id = "flutter-run";
      name = "Run Flutter";
      command = "flutter run -d web-server --web-port 8000";
      # Optional: set an icon for the command.
      icon = "flutter";
      # Optional: set a path to a file to open when the command is running.
      # openFile = "/path/to/your/file";
    }
  ];

  # IDX-specific settings.
  idx = {
    # Required for development with Flutter.
    previews.enable = true;
    previews.ID = "flutter-run";
    previews.openFile = "lib/main.dart";

    # Ports to expose to the outside world.
    ports.enable = true;
    ports.ports = [8000];
  };
}