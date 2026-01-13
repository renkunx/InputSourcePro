<p align="center">
    <a href="https://inputsource.pro" target="_blank">
        <img height="200" src="https://inputsource.pro/img/app-icon.png" alt="Input Source Pro Logo">
    </a>
</p>

<h1 align="center">Input Source Pro</h1>

<p align="center">Switch and track your input sources with ease ✨</p>

<p align="center">
    <a href="https://inputsource.pro" target="_blank">Website</a> ·
    <a href="https://inputsource.pro/changelog" target="_blank">Releases</a> ·
    <a href="https://github.com/runjuu/InputSourcePro/discussions">Discussions</a>
</p>

> **Input Source Pro** is a free and open-source macOS utility designed for multilingual users who frequently switch input sources. It automates input source switching based on the active application — or even the specific website you're browsing — significantly boosting your productivity and typing experience.

<table>
    <tr>
        <td>
            <a href="https://inputsource.pro">
                <img src="./imgs/switch-keyboard-base-on-app.gif"  alt="Switch Keyboard Based on App" width="100%">
            </a>
        </td>
        <td>
            <a href="https://inputsource.pro">
                <img src="./imgs/switch-keyboard-base-on-browser.gif"  alt="Switch Keyboard Based on Browser" width="100%">
            </a>
        </td>
    </tr>
</table>

<hr />

<p align="center">
  <a href="https://refine.sh?utm_source=github&utm_medium=readme&utm_campaign=inputsourcepro">
    <img src="https://refine.sh/banner.png" width="800" />
  </a>
</p>

<p align="center">
    🙌 Meet my new app: <a href="https://refine.sh/" target="_blank">Refine</a>, a local Grammarly alternative that runs 100% offline 🤩
</p>

<hr />

## Features

### 🥷 Automatic Context-Aware Switching
- Set a default input source per **application**.
- Set input sources per **website** when using supported browsers (Safari, Chrome, Arc, Edge, Vivaldi, Opera, Brave, Firefox, Zen, Dia, and more).
- Switch automatically as you move between apps/websites.

### 🐈‍⬛ Elegant Input Source Indicator
- Shows your current input source with a clean on-screen indicator.
- Customizable and designed to stay out of your way.

### ✍️ App-Aware Punctuation Modes
Keep punctuation consistent across different languages by enabling **Force English Punctuation** for specific apps.
- Automatically types standard symbols (`, . ; ' " [ ]`) even when your current input source would normally produce localized or full-width characters.
- Enable it only for the apps where you need it, such as code editors or terminal windows.

### 🎛️ App-Based Function Key Switching
Automatically switch your macOS function key mode per app.
- Choose whether an app should use **F1–F12** as:
    - **Standard Function Keys**: Acts as standard F1–F12 keys. Ideal for IDEs (e.g., VSCode) and games.
    - **Media Keys**: Triggers special features printed on the keys (e.g., brightness, volume, playback). Ideal for general daily use.
- Falls back to your system-wide/default setting when an app has no override.

### ⌨️ Custom Shortcuts
Switch input sources via either:
- **Keyboard Shortcuts**: Use standard key combinations.
- **Single Modifier Shortcuts**: Use a single key (Shift, Control, Option, or Command), triggered by pressing once or double-tapping.

### 😎 And Much More...

<a href="https://inputsource.pro">
    <img width="892" alt="image" src="https://github.com/user-attachments/assets/351e2ac9-27d8-402e-8739-21c3f604a3c1" />
</a>


## Installation

### Using Homebrew

```bash
brew install --cask input-source-pro
```

### Manual Download
Download the latest release from the [Releases page](https://inputsource.pro/changelog).

## Sponsors

This project is made possible by all the sponsors supporting my work:

<p align="center">
  <a href="https://github.com/sponsors/runjuu">
    <img src="https://github.com/runjuu/runjuu/raw/refs/heads/main/sponsorkit/sponsors.svg" alt="Logos from Sponsors" />
  </a>
</p>

## Contributing

Contributions are highly welcome! Whether you have a bug report, a feature suggestion, or want to contribute code, your help is appreciated.

* For detailed contribution steps, setup, and code guidelines, please read our [**Contributing Guidelines**](CONTRIBUTING.md).
* **Bug Reports:** Please submit bug reports via [**GitHub Issues**](https://github.com/runjuu/InputSourcePro/issues). Check existing issues first!
* **Feature Requests & Questions:** For suggesting new features, asking questions, or general discussion, please use [**GitHub Discussions**](https://github.com/runjuu/InputSourcePro/discussions).
* **Code of Conduct:** Please note that this project adheres to our [**Code of Conduct**](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Resources

### 🎹 Mechanical Keyboard Sound Effects (Developer Reference)

> Play mechanical keyboard sounds when typing. This section documents the sound file specifications for contributors who want to add or modify keyboard sound effects.

#### Sound File Specifications

| Property | Requirement |
|----------|-------------|
| Format | WAV |
| Encoding | PCM (AVAudioPlayer compatible) |
| Sample Rate | 44.1kHz or 48kHz recommended |
| Channels | Mono or Stereo |
| Bit Depth | 16-bit |
| Duration | 50-150ms (short, crisp keypress sound) |

#### Supported Switch Types

| File Name | Switch Type | Description |
|-----------|-------------|-------------|
| `keyboard_Blue.wav` | Blue Switch | Loud and clicky |
| `keyboard_Red.wav` | Red Switch | Smooth and quiet |
| `keyboard_Brown.wav` | Brown Switch | Tactile feedback |
| `keyboard_Black.wav` | Black Switch | Heavy and smooth |
| `keyboard_Clear.wav` | Clear Switch | Strong tactile bump |
| `keyboard_Silver.wav` | Silver Switch | Fast and light |

#### Playback Characteristics
- **Debounce Interval**: 20ms minimum between sounds to prevent overlap
- **Volume Control**: 0.0 ~ 1.0 (default 0.5)
- **Playback Mode**: Reset position on each keypress

#### File Location
Sound files must be placed in the Xcode project Bundle resources, ensuring they are included in **Build Phases → Copy Bundle Resources**.

## Building from Source
Clone the repository and build it using the latest version of Xcode:

```bash
git clone git@github.com:runjuu/InputSourcePro.git
```

Then open the project in Xcode and hit Build. 🍻

## License
Input Source Pro is licensed under the [GPL-3.0 License](LICENSE).
