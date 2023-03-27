# NuThoughts

NuThoughts is a note taking app focused on creating atomic notes. For each thought that you capture, a markdown file is created on the server host. This is ideal for adding atomic markdown files to a Logseq graph or Obsidian vault folder, assuming that you host the server on your own computer.

## Installation

### Flutter

Install Flutter for your operating system

- https://docs.flutter.dev/get-started/install

This app was scaffolded using Flutter v3.7.6. Please make sure you at least use this version.

### NuThoughts Server

Follow the installation and usage instructions for setting up your own NuThoughts server

- https://github.com/trey-wallis/nuthoughts-server

## Usage

### Development

Open a terminal and in the root directory of the repository run the project

- `flutter run`

### Production

- `flutter build`

## Debugging

If the app stalls during development on Android, you can try uninstalling it

- `adb uninstall com.example.nuthoughts`

Then try running the app again
