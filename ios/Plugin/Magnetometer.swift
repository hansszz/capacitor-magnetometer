import Foundation

@objc public class Magnetometer: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
