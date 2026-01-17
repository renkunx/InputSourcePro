import SwiftUI

struct KeyboardSoundSettingsView: View {
    @EnvironmentObject var preferencesVM: PreferencesVM
    @EnvironmentObject var permissionsVM: PermissionsVM

    @State private var isPlayingTestSound = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Permission Warning
                if !permissionsVM.isInputMonitoringEnabled {
                    permissionRequiredSection
                }

                // Main Toggle
                SettingsSection(title: "Keyboard Sound Effects") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Toggle("", isOn: $preferencesVM.preferences.isKeyboardSoundEnabled)
                                .disabled(!permissionsVM.isInputMonitoringEnabled)

                            Text("Enable Keyboard Sounds".i18n())

                            Spacer()
                        }

                        if !permissionsVM.isInputMonitoringEnabled {
                            Text("Input Monitoring permission is required".i18n())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }

                // Switch Type Selection
                if preferencesVM.preferences.isKeyboardSoundEnabled {
                    switchTypeSection
                    triggerModeSection
                    volumeSection
                    infoSection
                }
            }
            .padding()
        }
        .labelsHidden()
        .toggleStyle(.switch)
        .background(NSColor.background1.color)
    }

    private var permissionRequiredSection: some View {
        SettingsSection(title: "Permission Required") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)

                    Text("Permission Required".i18n())
                        .font(.headline)
                }

                Text("Keyboard Sound Effects requires Input Monitoring permission to detect keystrokes.".i18n())
                    .font(.body)

                Button(action: { openInputMonitoringPreferences() }) {
                    Text("Open Input Monitoring Preferences".i18n())
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    private var switchTypeSection: some View {
        SettingsSection(title: "Switch Type") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select your mechanical switch type:".i18n())
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                let columns = [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ]

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MechanicalSwitchType.allCases) { type in
                        SwitchTypeButton(
                            type: type,
                            isSelected: preferencesVM.preferences.keyboardSoundSwitchType == type
                        ) {
                            preferencesVM.update { $0.keyboardSoundSwitchType = type }
                        }
                    }
                }

                // Test Sound Button
                if let switchType = preferencesVM.preferences.keyboardSoundSwitchType,
                   switchType != .none {
                    HStack {
                        Button(action: { testSound(switchType) }) {
                            HStack {
                                Image(systemName: isPlayingTestSound ? "speaker.wave.3.fill" : "speaker.wave.2")
                                Text("Test Sound".i18n())
                            }
                        }
                        .disabled(isPlayingTestSound)

                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }

    private var triggerModeSection: some View {
        SettingsSection(title: "Trigger Mode") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose when sounds play:".i18n())
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Trigger Mode", selection: $preferencesVM.preferences.keyboardSoundTriggerMode) {
                    ForEach(KeyboardSoundTriggerMode.allCases) { mode in
                        Text(mode.name).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
            }
            .padding()
        }
    }

    private var volumeSection: some View {
        SettingsSection(title: "Volume") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(
                        value: $preferencesVM.preferences.keyboardSoundVolume,
                        in: 0.0...1.0,
                        step: 0.1
                    )
                    Image(systemName: "speaker.wave.3.fill")
                }

                Text("\(Int(preferencesVM.preferences.keyboardSoundVolume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    private var infoSection: some View {
        SettingsSection(title: "") {
            VStack(alignment: .leading, spacing: 8) {
                Text("About Keyboard Sounds".i18n())
                    .font(.headline)

                Text("This feature plays mechanical keyboard sound effects when you type. The sounds are played locally and do not affect system audio.".i18n())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    private func testSound(_ switchType: MechanicalSwitchType) {
        isPlayingTestSound = true

        // Post notification to trigger sound
        NotificationCenter.default.post(
            name: .testKeyboardSound,
            object: nil,
            userInfo: ["switchType": switchType]
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPlayingTestSound = false
        }
    }

    private func openInputMonitoringPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_InputMonitoring") {
            NSWorkspace.shared.open(url)
        }
    }
}

extension Notification.Name {
    static let testKeyboardSound = Notification.Name("testKeyboardSound")
}

// MARK: - Switch Type Button

struct SwitchTypeButton: View {
    let type: MechanicalSwitchType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .accentColor : .secondary)

                    Text(type.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()
                }

                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
