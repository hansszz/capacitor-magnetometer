import Foundation
import Capacitor
import CoreMotion

@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    private var isUpdating = false

    public override func load() {
        motionQueue.name = "MagnetometerMotionQueue"
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 1.0 / 60.0 // Default to ~60Hz
            print("Magnetometer is available and the default update interval is set.")
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

        let frequency = call.getFloat("frequency") ?? 1.0 // Default to 1 Hz if not provided
        motionManager.magnetometerUpdateInterval = 1.0 / Double(frequency)
        print("Starting magnetometer updates with frequency: \(frequency) Hz")

        motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (magnetometerData, error) in
            guard error == nil, let data = magnetometerData else {
                DispatchQueue.main.async {
                    call.reject("Error starting magnetometer updates: \(error?.localizedDescription ?? "Unknown error")")
                }
                return
            }

            var ret = JSObject()
            ret["x"] = data.magneticField.x
            ret["y"] = data.magneticField.y
            ret["z"] = data.magneticField.z
            DispatchQueue.main.async {
                self?.notifyListeners("magnetometerData", data: ret)
            }
        }

        isUpdating = true
        call.resolve()
    }

    @objc func stopMagnetometerUpdates(_ call: CAPPluginCall) {
        motionManager.stopMagnetometerUpdates()
        isUpdating = false
        print("Stopped magnetometer updates.")
        call.resolve()
    }

@objc private func appDidBecomeActive() {
    // Check if the updates were previously being received
    if isUpdating {
        // Reconfigure the motion manager if needed
        motionManager.magnetometerUpdateInterval = previousUpdateInterval // make sure this is stored somewhere

        // Restart the magnetometer updates
        motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (magnetometerData, error) in
            // Same as before
        }

        print("Attempted to resume magnetometer updates after becoming active.")
    }
}


    @objc private func appDidEnterBackground() {
        // Pause magnetometer updates to conserve battery
        motionManager.stopMagnetometerUpdates()
        print("Paused magnetometer updates after entering background.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        motionManager.stopMagnetometerUpdates()
        print("MagnetometerPlugin deinitialized.")
    }
}
