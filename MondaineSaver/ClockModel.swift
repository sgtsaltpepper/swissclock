import Foundation

enum SecondHandPhase {
    case sweep
    case pause
}

struct ClockSnapshot {
    let displayedHour: Int
    let displayedMinute: Int
    let displayedSecond: Int
    let fractionalSecond: Double
    let hourProgress: Double
    let minuteProgress: Double
    let secondProgress: Double
    let secondHandPhase: SecondHandPhase
}

enum MondaineClockModel {
    private static let secondsSweepDuration = 58.5
    private static let holdDuration = 1.5

    private static func springProgress(time: Double) -> Double {
        let w = 20.0
        let d = 8.0
        return 1.0 - exp(-d * time) * (cos(w * time) + (d/w) * sin(w * time))
    }


    static func snapshot(at date: Date, calendar: Calendar = .current) -> ClockSnapshot {
        let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)

        let displayedHour = components.hour ?? 0
        let displayedMinute = components.minute ?? 0
        let displayedSecond = components.second ?? 0
        let nanosecond = Double(components.nanosecond ?? 0)
        let fractionalSecond = Double(displayedSecond) + nanosecond / 1_000_000_000

        let hourInCycle = Double(displayedHour).truncatingRemainder(dividingBy: 12.0)
        
        var animatedMinuteValue = Double(displayedMinute)
        if fractionalSecond < 0.6 {
            animatedMinuteValue = Double(displayedMinute - 1) + springProgress(time: fractionalSecond)
        }

        let minuteProgress = animatedMinuteValue / 60.0
        let hourProgress = (hourInCycle + (animatedMinuteValue + fractionalSecond / 60.0) / 60.0) / 12.0

        let secondHandPhase: SecondHandPhase = fractionalSecond >= secondsSweepDuration ? .pause : .sweep
        let secondProgress = min(fractionalSecond / secondsSweepDuration, 1.0)

        return ClockSnapshot(
            displayedHour: displayedHour,
            displayedMinute: displayedMinute,
            displayedSecond: displayedSecond,
            fractionalSecond: fractionalSecond,
            hourProgress: hourProgress,
            minuteProgress: minuteProgress,
            secondProgress: secondProgress,
            secondHandPhase: secondHandPhase
        )
    }

    static var frameInterval: TimeInterval {
        1.0 / 60.0
    }

    static var fullCycleDuration: TimeInterval {
        secondsSweepDuration + holdDuration
    }
}
