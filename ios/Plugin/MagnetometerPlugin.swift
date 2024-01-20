import Foundation
import Capacitor
import CoreMotion

@objc(MagnetometerPlugin)
public class MagnetometerPlugin: CAPPlugin {
    private var motionManager: CMMotionManager?
    private let motionQueue = OperationQueue()
    private var isUpdating = false
    private var previousUpdateInterval: TimeInterval = 1.0 / 60.0 // Default to ~60Hz

    public override func load() {
        motionQueue.name = "MagnetometerMotionQueue"
        initializeMotionManager()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    private func initializeMotionManager() {
        motionManager = CMMotionManager()
        if let motionManager = motionManager, motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = previousUpdateInterval
            print("Magnetometer is available. Default update interval set to \(previousUpdateInterval) seconds.")
        } else {
            print("Magnetometer is not available on this device.")
        }
    }

    @objc func startMagnetometerUpdates(_ call: CAPPluginCall) {
        guard let motionManager = motionManager, motionManager.isMagnetometerAvailable else {
            call.reject("Magnetometer sensor not available.")
            return
        }

        let frequency = call.getFloat("frequency") ?? 1.0 // Use 1 Hz if not provided
        previousUpdateInterval = 1.0 / Double(frequency)
        motionManager.magnetometerUpdateInterval = previousUpdateInterval
        print("Starting magnetometer updates with frequency: \(frequency) Hz")

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
        motionManager?.stopMagnetometerUpdates()
        isUpdating = false
        print("Stopped magnetometer updates.")
        call.resolve()
    }

    @objc private func appDidBecomeActive() {
        if isUpdating {
            print("App became active. Attempting to resume magnetometer updates.")
            initializeMotionManager()
            startMagnetometerUpdates(CAPPluginCall(callbackId: "resumeUpdates", options: [:], success: { _,_  in }, error: { _ in }))
        }


    }

    @objc private func appDidEnterBackground() {
        if isUpdating {
            print("App entered background. Pausing magnetometer updates to conserve battery.")
            motionManager?.stopMagnetometerUpdates()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        motionManager?.stopMagnetometerUpdates()
        print("MagnetometerPlugin deinitialized.")
    }
}
