import AppKit
import AVFoundation
import Combine
import Carbon

@MainActor
class KeyboardSoundService: ObservableObject {
    private let logger = ISPLogger(category: String(describing: KeyboardSoundService.self))

    private var isEnabled = false
    private var eventTap: CFMachPort?
    private var eventRunLoopSource: CFRunLoopSource?
    private weak var preferencesVM: PreferencesVM?

    // Audio players for different switch types
    private var audioPlayers: [MechanicalSwitchType: AVAudioPlayer] = [:]
    private var currentVolume: Float = 0.5

    // Debounce/throttle to prevent sound overlap
    private var lastSoundTime: TimeInterval = 0
    private let minimumSoundInterval: TimeInterval = 0.02  // 20ms between sounds

    // Key code filtering
    private let modifierKeyCodes: Set<UInt16> = [
        UInt16(kVK_Command),
        UInt16(kVK_RightCommand),
        UInt16(kVK_Shift),
        UInt16(kVK_RightShift),
        UInt16(kVK_Control),
        UInt16(kVK_RightControl),
        UInt16(kVK_Option),
        UInt16(kVK_RightOption),
        UInt16(kVK_Function)
    ]

    private let spaceKeyCode: UInt16 = UInt16(kVK_Space)

    init(preferencesVM: PreferencesVM) {
        self.preferencesVM = preferencesVM
        loadSoundFiles()
    }

    // MARK: - Lifecycle

    func enable() {
        guard !isEnabled else { return }

        logger.debug { "Enabling keyboard sound effects" }
        let success = startMonitoring()

        if success {
            isEnabled = true
            updateSettings()
            logger.debug { "Keyboard sound effects enabled" }
        } else {
            logger.debug { "Failed to enable keyboard sound effects" }
        }
    }

    func disable() {
        guard isEnabled else { return }

        logger.debug { "Disabling keyboard sound effects" }
        stopMonitoring()
        isEnabled = false
    }

    deinit {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
    }

    // MARK: - Audio Management

    private func loadSoundFiles() {
        // Load sound files from bundle for each switch type
        for switchType in MechanicalSwitchType.allCases {
            if let url = Bundle.main.url(forResource: "keyboard_\(switchType.rawValue)", withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[switchType] = player
                    logger.debug { "Loaded sound for \(switchType.rawValue) switch" }
                } catch {
                    logger.debug { "Failed to load sound for \(switchType.rawValue): \(error)" }
                }
            } else {
                logger.debug { "Sound file not found for \(switchType.rawValue)" }
            }
        }
    }

    func playSound(switchType: MechanicalSwitchType) {
        guard let player = audioPlayers[switchType] else { return }

        let currentTime = ProcessInfo.processInfo.systemUptime
        guard currentTime - lastSoundTime >= minimumSoundInterval else { return }

        player.volume = currentVolume
        player.currentTime = 0
        player.play()

        lastSoundTime = currentTime
    }

    // MARK: - Event Monitoring

    private func startMonitoring() -> Bool {
        stopMonitoring()

        let eventMask = (1 << CGEventType.keyDown.rawValue)

        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon,
                  let service = Unmanaged<KeyboardSoundService>.fromOpaque(refcon).takeUnretainedValue() as? KeyboardSoundService
            else {
                return Unmanaged.passUnretained(event)
            }

            return service.handleKeyEvent(proxy: proxy, type: type, event: event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            logger.debug { "Failed to create event tap for keyboard sounds" }
            return false
        }

        eventRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let runLoopSource = eventRunLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)

        return true
    }

    private func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }

        if let runLoopSource = eventRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.eventRunLoopSource = nil
        }
    }

    private func handleKeyEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent> {
        guard isEnabled, type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }

        guard let preferencesVM = preferencesVM else {
            return Unmanaged.passUnretained(event)
        }

        // Check if feature is enabled
        guard preferencesVM.preferences.isKeyboardSoundEnabled,
              let switchType = preferencesVM.preferences.keyboardSoundSwitchType,
              switchType != .none else {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        // Apply trigger mode filtering
        let triggerMode = preferencesVM.preferences.keyboardSoundTriggerMode ?? .allKeys
        if !shouldPlaySoundForKey(keyCode: keyCode, mode: triggerMode) {
            return Unmanaged.passUnretained(event)
        }

        // Play sound
        playSound(switchType: switchType)

        return Unmanaged.passUnretained(event)
    }

    private func shouldPlaySoundForKey(keyCode: UInt16, mode: KeyboardSoundTriggerMode) -> Bool {
        switch mode {
        case .allKeys:
            return true
        case .characterKeysOnly:
            return !modifierKeyCodes.contains(keyCode)
        case .excludeModifiers:
            return !modifierKeyCodes.contains(keyCode)
        case .excludeSpace:
            return keyCode != spaceKeyCode
        }
    }

    // MARK: - Settings Updates

    func updateSettings() {
        guard let preferencesVM = preferencesVM else { return }

        currentVolume = Float(preferencesVM.preferences.keyboardSoundVolume)

        // Enable/disable based on preference
        if preferencesVM.preferences.isKeyboardSoundEnabled {
            enable()
        } else {
            disable()
        }
    }
}
