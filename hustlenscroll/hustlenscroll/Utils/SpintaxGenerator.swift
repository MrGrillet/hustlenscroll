import Foundation

struct SpintaxGenerator {
    static func spin(_ text: String) -> String {
        var result = text
        while let range = result.range(of: "{[^{}]*}", options: .regularExpression) {
            let options = result[range].dropFirst().dropLast().split(separator: "|")
            if let randomOption = options.randomElement() {
                result.replaceSubrange(range, with: String(randomOption))
            }
        }
        return result
    }
} 