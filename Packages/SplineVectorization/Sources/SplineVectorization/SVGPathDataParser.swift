import CoreGraphics
import Foundation

struct SVGPathDataParser {
    private let pathData: String

    init(pathData: String) {
        self.pathData = pathData
    }

    func parseCommands() -> [SVGPathCommand] {
        let tokens = tokenizePathData(pathData)
        var state = SVGPathParseState(tokens: tokens)

        while state.index < state.tokens.count {
            if let commandToken = state.currentCommandToken {
                state.currentCommand = commandToken
                state.index += 1
            }

            guard let command = state.currentCommand else {
                break
            }

            if consumeMove(command: command, state: &state) { continue }
            if consumeLineFamily(command: command, state: &state) { continue }
            if consumeCubicFamily(command: command, state: &state) { continue }
            if consumeQuadFamily(command: command, state: &state) { continue }
            if consumeArcFamily(command: command, state: &state) { continue }
            if consumeClose(command: command, state: &state) { continue }

            state.index += 1
        }

        return state.commands
    }
}

private enum SVGPathToken {
    case command(Character)
    case number(Double)
}

private struct SVGPathParseState {
    let tokens: [SVGPathToken]
    var index: Int = 0
    var commands: [SVGPathCommand] = []
    var currentPoint: CGPoint = .zero
    var subpathStart: CGPoint = .zero
    var previousCubicControl: CGPoint?
    var previousQuadControl: CGPoint?
    var currentCommand: Character?

    var currentCommandToken: Character? {
        guard index < tokens.count else { return nil }
        if case let .command(command) = tokens[index] {
            return command
        }
        return nil
    }

    mutating func readNumber() -> CGFloat? {
        guard index < tokens.count else { return nil }
        guard case let .number(value) = tokens[index] else { return nil }
        index += 1
        return CGFloat(value)
    }

    mutating func readPoint(relative: Bool) -> CGPoint? {
        guard let xValue = readNumber(), let yValue = readNumber() else {
            return nil
        }

        if relative {
            return CGPoint(x: currentPoint.x + xValue, y: currentPoint.y + yValue)
        }

        return CGPoint(x: xValue, y: yValue)
    }
}

private func consumeMove(command: Character, state: inout SVGPathParseState) -> Bool {
    let relative = command == "m"
    guard command == "M" || relative else {
        return false
    }

    guard let firstPoint = state.readPoint(relative: relative) else {
        return false
    }

    state.commands.append(.moveTo(firstPoint))
    state.currentPoint = firstPoint
    state.subpathStart = firstPoint
    state.previousCubicControl = nil
    state.previousQuadControl = nil

    while let linePoint = state.readPoint(relative: relative) {
        state.commands.append(.lineTo(linePoint))
        state.currentPoint = linePoint
    }

    return true
}

private func consumeLineFamily(command: Character, state: inout SVGPathParseState) -> Bool {
    if command == "L" || command == "l" {
        return consumeLine(relative: command == "l", state: &state)
    }
    if command == "H" || command == "h" {
        return consumeHorizontal(relative: command == "h", state: &state)
    }
    if command == "V" || command == "v" {
        return consumeVertical(relative: command == "v", state: &state)
    }
    return false
}

private func consumeCubicFamily(command: Character, state: inout SVGPathParseState) -> Bool {
    if command == "C" || command == "c" {
        return consumeCubic(relative: command == "c", state: &state)
    }
    if command == "S" || command == "s" {
        return consumeSmoothCubic(relative: command == "s", state: &state)
    }
    return false
}

private func consumeQuadFamily(command: Character, state: inout SVGPathParseState) -> Bool {
    if command == "Q" || command == "q" {
        return consumeQuad(relative: command == "q", state: &state)
    }
    if command == "T" || command == "t" {
        return consumeSmoothQuad(relative: command == "t", state: &state)
    }
    return false
}

private func consumeArcFamily(command: Character, state: inout SVGPathParseState) -> Bool {
    if command == "A" || command == "a" {
        return consumeArc(relative: command == "a", state: &state)
    }
    return false
}

private func consumeClose(command: Character, state: inout SVGPathParseState) -> Bool {
    guard command == "Z" || command == "z" else {
        return false
    }

    state.commands.append(.close)
    state.currentPoint = state.subpathStart
    state.previousCubicControl = nil
    state.previousQuadControl = nil
    return true
}

private func consumeLine(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while let point = state.readPoint(relative: relative) {
        state.commands.append(.lineTo(point))
        state.currentPoint = point
        state.previousCubicControl = nil
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func consumeHorizontal(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while let xValue = state.readNumber() {
        let point = CGPoint(
            x: relative ? state.currentPoint.x + xValue : xValue,
            y: state.currentPoint.y
        )
        state.commands.append(.lineTo(point))
        state.currentPoint = point
        state.previousCubicControl = nil
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func consumeVertical(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while let yValue = state.readNumber() {
        let point = CGPoint(
            x: state.currentPoint.x,
            y: relative ? state.currentPoint.y + yValue : yValue
        )
        state.commands.append(.lineTo(point))
        state.currentPoint = point
        state.previousCubicControl = nil
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func consumeCubic(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while true {
        guard let control1 = state.readPoint(relative: relative),
              let control2 = state.readPoint(relative: relative),
              let end = state.readPoint(relative: relative) else {
            break
        }

        state.commands.append(.cubicCurveTo(control1: control1, control2: control2, end: end))
        state.currentPoint = end
        state.previousCubicControl = control2
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func consumeSmoothCubic(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while true {
        guard let control2 = state.readPoint(relative: relative),
              let end = state.readPoint(relative: relative) else {
            break
        }

        let control1 = reflectedControl(previous: state.previousCubicControl, current: state.currentPoint)
        state.commands.append(.cubicCurveTo(control1: control1, control2: control2, end: end))
        state.currentPoint = end
        state.previousCubicControl = control2
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func consumeQuad(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while true {
        guard let control = state.readPoint(relative: relative),
              let end = state.readPoint(relative: relative) else {
            break
        }

        state.commands.append(.quadCurveTo(control: control, end: end))
        state.currentPoint = end
        state.previousQuadControl = control
        state.previousCubicControl = nil
        consumed = true
    }

    return consumed
}

private func consumeSmoothQuad(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while let end = state.readPoint(relative: relative) {
        let control = reflectedControl(previous: state.previousQuadControl, current: state.currentPoint)
        state.commands.append(.quadCurveTo(control: control, end: end))
        state.currentPoint = end
        state.previousQuadControl = control
        state.previousCubicControl = nil
        consumed = true
    }

    return consumed
}

private func consumeArc(relative: Bool, state: inout SVGPathParseState) -> Bool {
    var consumed = false

    while true {
        guard state.readNumber() != nil,
              state.readNumber() != nil,
              state.readNumber() != nil,
              state.readNumber() != nil,
              state.readNumber() != nil,
              let xValue = state.readNumber(),
              let yValue = state.readNumber() else {
            break
        }

        let end = CGPoint(
            x: relative ? state.currentPoint.x + xValue : xValue,
            y: relative ? state.currentPoint.y + yValue : yValue
        )

        state.commands.append(.lineTo(end))
        state.currentPoint = end
        state.previousCubicControl = nil
        state.previousQuadControl = nil
        consumed = true
    }

    return consumed
}

private func reflectedControl(previous: CGPoint?, current: CGPoint) -> CGPoint {
    guard let previous else {
        return current
    }

    let deltaX = current.x - previous.x
    let deltaY = current.y - previous.y
    return CGPoint(x: current.x + deltaX, y: current.y + deltaY)
}

private func tokenizePathData(_ data: String) -> [SVGPathToken] {
    var tokens: [SVGPathToken] = []
    var index = data.startIndex

    while index < data.endIndex {
        let character = data[index]

        if character.isWhitespace || character == "," {
            index = data.index(after: index)
            continue
        }

        if character.isLetter {
            tokens.append(.command(character))
            index = data.index(after: index)
            continue
        }

        let start = index
        index = data.index(after: index)

        while index < data.endIndex {
            let currentCharacter = data[index]
            if currentCharacter.isWhitespace || currentCharacter == "," || currentCharacter.isLetter {
                break
            }

            if currentCharacter == "-" {
                let previousIndex = data.index(before: index)
                let previousCharacter = data[previousIndex]
                if previousCharacter != "e" && previousCharacter != "E" {
                    break
                }
            }

            index = data.index(after: index)
        }

        let value = String(data[start..<index])
        if let number = Double(value) {
            tokens.append(.number(number))
        }
    }

    return tokens
}
