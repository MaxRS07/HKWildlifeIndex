

import Foundation

extension BinaryFloatingPoint {
    func clamp(_ min: Self,_ max: Self) -> Self {
        return self > max ? max : self < min ? min : self
    }
}
public extension Array {
    @inlinable mutating func removeFirst(where isRemoved: (Self.Element) throws -> Bool) rethrows -> Self.Element? {
        for (index, element) in self.enumerated() {
            if try isRemoved(element) {
                self.remove(at: index)
                return element
            }
        }
        return nil
    }
}
public extension String {
    func splitCamel() -> Self {
        if self.isEmpty {return self}
        var str = self.split(separator: "").map {
            ($0.filter {$0.isUppercase} == $0) ? " " + $0 : $0
        }.joined()
        if str.first == " " {
            str.removeFirst()
        }
        return str
    }
}
