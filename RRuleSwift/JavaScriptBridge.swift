//
//  JavaScriptBridge.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import EventKit

internal extension RecurrenceFrequency {
    private func toJSONFrequency() -> String {
        switch self {
        case .Secondly: return "RRule.SECONDLY"
        case .Minutely: return "RRule.MINUTELY"
        case .Hourly: return "RRule.HOURLY"
        case .Daily: return "RRule.DAILY"
        case .Weekly: return "RRule.WEEKLY"
        case .Monthly: return "RRule.MONTHLY"
        case .Yearly: return "RRule.YEARLY"
        }
    }
}

internal extension EKWeekday {
    private func toJSONSymbol() -> String {
        switch self {
        case .Monday: return "RRule.MO"
        case .Tuesday: return "RRule.TU"
        case .Wednesday: return "RRule.WE"
        case .Thursday: return "RRule.TH"
        case .Friday: return "RRule.FR"
        case .Saturday: return "RRule.SA"
        case .Sunday: return "RRule.SU"
        }
    }
}

internal extension RecurrenceRule {
    internal func toJSONString() -> String? {
        guard let frequency = frequency else {
            return nil
        }

        var jsonString = "freq: \(frequency.toJSONFrequency()),"
        jsonString += "interval: \(max(1, interval)),"
        jsonString += "wkst: \(firstDayOfWeek.toJSONSymbol()),"
        jsonString += "dtstart: new Date('\(RRule.ISO8601DateFormatter.stringFromDate(startDate))'),"

        if let endDate = recurrenceEnd?.endDate {
            jsonString += "until: new Date('\(RRule.ISO8601DateFormatter.stringFromDate(endDate))'),"
        } else if let count = recurrenceEnd?.occurrenceCount {
            jsonString += "count: \(count),"
        } else {
            jsonString += "count: \(Generator.endlessRecurrenceCount),"
        }

        if let bysetpos = bysetpos {
            let bysetposStrings = bysetpos.flatMap({ (setpo) -> String? in
                guard (-366...366 ~= setpo) && (setpo != 0) else {
                    return nil
                }
                return String(setpo)
            })
            if bysetposStrings.count > 0 {
                jsonString += "bysetpos: [\(bysetposStrings.joinWithSeparator(","))],"
            }
        }

        if let byyearday = byyearday {
            let byyeardayStrings = byyearday.flatMap({ (yearday) -> String? in
                guard (-366...366 ~= yearday) && (yearday != 0) else {
                    return nil
                }
                return String(yearday)
            })
            if byyeardayStrings.count > 0 {
                jsonString += "byyearday: [\(byyeardayStrings.joinWithSeparator(","))],"
            }
        }

        if let bymonth = bymonth {
            let bymonthStrings = bymonth.flatMap({ (month) -> String? in
                guard 1...12 ~= month else {
                    return nil
                }
                return String(month)
            })
            if bymonthStrings.count > 0 {
                jsonString += "bymonth: [\(bymonthStrings.joinWithSeparator(","))],"
            }
        }

        if let byweekno = byweekno {
            let byweeknoStrings = byweekno.flatMap({ (weekno) -> String? in
                guard (-53...53 ~= weekno) && (weekno != 0) else {
                    return nil
                }
                return String(weekno)
            })
            if byweeknoStrings.count > 0 {
                jsonString += "byweekno: [\(byweeknoStrings.joinWithSeparator(","))],"
            }
        }

        if let bymonthday = bymonthday {
            let bymonthdayStrings = bymonthday.flatMap({ (monthday) -> String? in
                guard (-31...31 ~= monthday) && (monthday != 0) else {
                    return nil
                }
                return String(monthday)
            })
            if bymonthdayStrings.count > 0 {
                jsonString += "bymonthday: [\(bymonthdayStrings.joinWithSeparator(","))],"
            }
        }

        if let byweekday = byweekday {
            let byweekdayJSSymbols = byweekday.map({ (weekday) -> String in
                return weekday.toJSONSymbol()
            })
            if byweekdayJSSymbols.count > 0 {
                jsonString += "byweekday: [\(byweekdayJSSymbols.joinWithSeparator(","))],"
            }
        }

        if let byhour = byhour {
            let byhourStrings = byhour.flatMap({ (hour) -> String? in
                guard 0...23 ~= hour else {
                    return nil
                }
                return String(hour)
            })
            if byhourStrings.count > 0 {
                jsonString += "byhour: [\(byhourStrings.joinWithSeparator(","))],"
            }
        }

        if let byminute = byminute {
            let byminuteStrings = byminute.flatMap({ (minute) -> String? in
                guard 0...59 ~= minute else {
                    return nil
                }
                return String(minute)
            })
            if byminuteStrings.count > 0 {
                jsonString += "byminute: [\(byminuteStrings.joinWithSeparator(","))],"
            }
        }

        if let bysecond = bysecond {
            let bysecondStrings = bysecond.flatMap({ (second) -> String? in
                guard 0...59 ~= second else {
                    return nil
                }
                return String(second)
            })
            if bysecondStrings.count > 0 {
                jsonString += "bysecond: [\(bysecondStrings.joinWithSeparator(","))]"
            }
        }

        if jsonString.substringFromIndex(jsonString.endIndex.advancedBy(-1)) == "," {
            jsonString.removeAtIndex(jsonString.endIndex.advancedBy(-1))
        }

        return jsonString
    }
}
