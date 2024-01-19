import Foundation
import Capacitor
import CoreMotion

@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()

    public override func load() {
        motionQueue.name = "MagnetometerMotionQueue"
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.016 // Default to ~60Hz
            print("Magnetometer is available and the default update interval is set.")
        } else {
            print("Magnetometer is not available on this device.")
        }
    }

    @objc func startMagnetometerUpdates(_ call: CAPPluginCall) {
        guard motionManager.isMagnetometerAvailable else {
            call.reject("Magnetometer sensor not available.")
            print("Magnetometer sensor not available - cannot start updates.")
            return
        }

        let frequency = call.getFloat("frequency") ?? 60.0 // Default to 60 Hz if not provided
        motionManager.magnetometerUpdateInterval = 1.0 / Double(frequency)
        print("Starting magnetometer updates with frequency: \(frequency) Hz")

        motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (magnetometerData, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    call.reject("Error starting magnetometer updates: \(error!.localizedDescription)")
                }
                print("Error starting magnetometer updates: \(error!.localizedDescription)")
                return
            }

            if let data = magnetometerData {
                var ret = JSObject()
                ret["x"] = data.magneticField.x
                ret["y"] = data.magneticField.y
                ret["z"] = data.magneticField.z
                DispatchQueue.main.async {
                    self?.notifyListeners("magnetometerData", data: ret)
                }
                print("Magnetometer data: \(ret)")
            }
        }

        call.resolve()
    }

    @objc func stopMagnetometerUpdates(_ call: CAPPluginCall) {
        motionManager.stopMagnetometerUpdates()
        print("Stopped magnetometer updates.")
        call.resolve()
    }

    deinit {
        // Clean up the magnetometer updates when the plugin is destroyed
        motionManager.stopMagnetometerUpdates()
        print("MagnetometerPlugin deinitialized.")
    }
}

