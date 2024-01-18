import Capacitor
import CoreMotion

@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private let motionManager = CMMotionManager()

    @objc func startMagnetometerUpdates(_ call: CAPPluginCall) {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 1.0 / 60.0 // Set the update interval (e.g., 60 Hz)
            motionManager.startMagnetometerUpdates(to: .main) { (data, error) in
                if let magneticField = data?.magneticField {
                    let result: [String: Any] = [
                        "x": magneticField.x,
                        "y": magneticField.y,
                        "z": magneticField.z
                    ]
                    call.resolve(result)
                } else {
                    call.reject("Failed to get magnetometer data.")
                }
            }
        } else {
            call.reject("Magnetometer sensor not available.")
        }
    }

    @objc func stopMagnetometerUpdates(_ call: CAPPluginCall) {
        motionManager.stopMagnetometerUpdates()
        call.resolve()
    }
}
