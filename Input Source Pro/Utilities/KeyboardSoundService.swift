import AppKit
import AVFoundation
import Combine
import Carbon

// MARK: - Audio Player Pool

/// Manages a pool of AVAudioPlayer instances for concurrent sound playback
private class AudioPlayerPool {
    private var players: [AVAudioPlayer] = []
    private let soundFileURL: URL
    private let maxPoolSize: Int

    init(soundFileURL: URL, maxPoolSize: Int = 8) {
        self.soundFileURL = soundFileURL
        self.maxPoolSize = maxPoolSize
    }

    /// Acquires a player from the pool.
    /// Strategy: reuse idle player → create new (if pool not full) → reuse oldest
    func acquirePlayer() -> AVAudioPlayer? {
        // 1. Reuse an idle player
        if let index = players.firstIndex(where: { !$0.isPlaying }) {
            let player = players[index]
            player.currentTime = 0
            return player
        }

        // 2. Create new player if pool not full
        if players.count < maxPoolSize {
            if let newPlayer = try? AVAudioPlayer(contentsOf: soundFileURL) {
                newPlayer.prepareToPlay()
                players.append(newPlayer)
                return newPlayer
            }
        }

        // 3. Pool full, reuse the oldest player
        if let oldestPlayer = players.first {
            oldestPlayer.currentTime = 0
            return oldestPlayer
        }

        return nil
    }

    /// Sets volume for all players in the pool
    func setVolume(_ volume: Float) {
        players.forEach { $0.volume = volume }
    }
}

// MARK: - Keyboard Sound Service

@MainActor
class KeyboardSoundService: ObservableObject {
    private let logger = ISPLogger(category: String(describing: KeyboardSoundService.self))

    private var isEnabled = false
    private var eventTap: CFMachPort?
    private var eventRunLoopSource: CFRunLoopSource?
    private weak var preferencesVM: PreferencesVM?

    // Audio player pools for different switch types
    private var playerPools: [MechanicalSwitchType: AudioPlayerPool] = [:]
    private var currentVolume: Float = 0.5

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
        // Create player pools for each switch type
        for switchType in MechanicalSwitchType.allCases {
            let resourceName = "keyboard_\(switchType.rawValue)"
            if let url = Bundle.main.url(forResource: resourceName, withExtension: "wav") {
                let pool = AudioPlayerPool(soundFileURL: url, maxPoolSize: 8)
                playerPools[switchType] = pool
                logger.debug { "Loaded sound pool for \(switchType.rawValue) switch from \(resourceName).wav" }

                // Test if audio can be loaded
                if let testPlayer = try? AVAudioPlayer(contentsOf: url) {
                    logger.debug { "Successfully tested audio for \(switchType.rawValue), duration: \(testPlayer.duration)s" }
                } else {
                    logger.debug { "WARNING: Failed to create test audio player for \(switchType.rawValue)" }
                }
            } else {
                logger.debug { "Sound file not found for \(switchType.rawValue) (looking for \(resourceName).wav)" }
                logger.debug { "Bundle resources: \(Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: nil) ?? [])" }
            }
        }
    }

    func playSound(switchType: MechanicalSwitchType) {
        guard let pool = playerPools[switchType] else {
            logger.debug { "No player pool found for \(switchType.rawValue)" }
            return
        }
        guard let player = pool.acquirePlayer() else {
            logger.debug { "Failed to acquire player for \(switchType.rawValue)" }
            return
        }

        player.volume = currentVolume
        logger.debug { "Playing sound for \(switchType.rawValue) at volume \(currentVolume)" }
        player.play()
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

        // Update volume for all player pools
        playerPools.values.forEach { $0.setVolume(currentVolume) }

        // Enable/disable based on preference
        if preferencesVM.preferences.isKeyboardSoundEnabled {
            enable()
        } else {
            disable()
        }
    }
}
