import Foundation
import Capacitor
import CoreMotion

@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    private var isUpdating = false
    private var previousUpdateInterval: TimeInterval = 1.0 / 60.0 // Default to ~60Hz

    public override func load() {
        motionQueue.name = "MagnetometerMotionQueue"
        motionManager.magnetometerUpdateInterval = previousUpdateInterval

        if motionManager.isMagnetometerAvailable {
            print("Magnetometer is available. Default update interval set to \(previousUpdateInterval) seconds.")
        } else {
            print("Magnetometer is not available on this device.")
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc func startMagnetometerUpdates(_ call: CAPPluginCall) {
        guard motionManager.isMagnetometerAvailable else {
            call.reject("Magnetometer sensor not available.")
            return
        }

        let frequency = call.getFloat("frequency") ?? 1.0 // Use 1 Hz if not provided
        previousUpdateInterval = 1.0 / Double(frequency)
        motionManager.magnetometerUpdateInterval = previousUpdateInterval
        print("Requested start of magnetometer updates with frequency: \(frequency) Hz")

        motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (magnetometerData, error) in
            guard error == nil, let data = magnetometerData else {
                DispatchQueue.main.async {
                    call.reject("Error starting magnetometer updates: \(error?.localizedDescription ?? "Unknown error")")
                }
                print("Error encountered: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var ret = JSObject()
            ret["x"] = data.magneticField.x
            ret["y"] = data.magneticField.y
            ret["z"] = data.magneticField.z
            DispatchQueue.main.async {
                self?.notifyListeners("magnetometerData", data: ret)
            }
            print("Magnetometer data received: x: \(data.magneticField.x), y: \(data.magneticField.y), z: \(data.magneticField.z)")
        }

        isUpdating = true
        call.resolve()
    }

    @objc func stopMagnetometerUpdates(_ call: CAPPluginCall) {
        if isUpdating {
            motionManager.stopMagnetometerUpdates()
            isUpdating = false
            print("Magnetometer updates stopped.")
        } else {
            print("Magnetometer updates were not running; no need to stop.")
        }
        call.resolve()
    }

    @objc private func appDidBecomeActive() {
        if isUpdating {
            motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (magnetometerData, error) in
                // ... existing update handling code
            }
            print("Resumed magnetometer updates after becoming active.")
        } else {
            print("App became active, but magnetometer updates are not set to resume.")
        }
    }

    @objc private func appDidEnterBackground() {
        if isUpdating {
            motionManager.stopMagnetometerUpdates()
            print("Paused magnetometer updates after entering background.")
        } else {
            print("App entered background, but magnetometer updates were not active.")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if isUpdating {
            motionManager.stopMagnetometerUpdates()
        }
        print("MagnetometerPlugin deinitialized.")
    }
}
