import Foundation
import Capacitor
import CoreMotion


@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private let motionManager = CMMotionManager()
    private var magnetometerUpdateTimer: Timer?


    @objc func startMagnetometerUpdates(_ call: CAPPluginCall) {
        let frequency = call.getFloat("frequency") ?? 60.0 // Default to 60 Hz if not provided

        guard motionManager.isMagnetometerAvailable else {
            call.reject("Magnetometer sensor not available.")
            return
        }

        motionManager.magnetometerUpdateInterval = TimeInterval(1.0 / frequency)

        motionManager.startMagnetometerUpdates()

        // Use a timer to retrieve and send magnetometer data at the requested frequency
        magnetometerUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(frequency), repeats: true) { [weak self] _ in
            if let magnetometerData = self?.motionManager.magnetometerData {
                let data = [
                    "x": magnetometerData.magneticField.x,
                    "y": magnetometerData.magneticField.y,
                    "z": magnetometerData.magneticField.z
                ]
                self?.notifyListeners("magnetometerData", data: data)
            }
        }

        call.resolve()
    }


    @objc func stopMagnetometerUpdates(_ call: CAPPluginCall) {
        motionManager.stopMagnetometerUpdates()

        // Invalidate and nullify the timer
        magnetometerUpdateTimer?.invalidate()
        magnetometerUpdateTimer = nil

        call.resolve()
    }
    
    public override func load() {
        // Set up any needed initialization and observers for lifecycle notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIScene.didActivateNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIScene.willDeactivateNotification,
                                               object: nil)
    }

    @objc func appDidBecomeActive(notification: NSNotification) {
        // Handle the app becoming active
    }

    @objc func appWillResignActive(notification: NSNotification) {
        // Handle the app going to the background
    }

    deinit {
        // Clean up observers when the plugin is destroyed
        NotificationCenter.default.removeObserver(self)
    }

}
