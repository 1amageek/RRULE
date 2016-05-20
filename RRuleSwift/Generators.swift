//
//  Generators.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import JavaScriptCore

internal struct Generator {
    static let endlessRecurrenceCount = 500
}

public extension RecurrenceRule {
    public func allOccurrences(endlessRecurrenceCount: Int = Generator.endlessRecurrenceCount) -> [NSDate] {
        guard let rrulejs = JavaScriptBridge.rrulejs() else {
            return []
        }

        let ruleJSONString = toJSONString(endlessRecurrenceCount: endlessRecurrenceCount)
        let context = JSContext()
        context.exceptionHandler = { context, exception in
            print("[RRuleSwift] rrule.js error: \(exception)")
        }
        context.evaluateScript(rrulejs)
        context.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard let allOccurrences = context.evaluateScript("rule.all()").toArray() as? [NSDate] else {
            return []
        }

        var occurrences = allOccurrences
        if let rdates = rdate?.dates {
            occurrences.appendContentsOf(rdates)
        }

        if let exdates = exdate?.dates, unit = exdate?.unit {
            for occurrence in occurrences {
                for exdate in exdates {
                    if calendar.isDate(occurrence, equalToDate: exdate, toUnitGranularity: unit) {
                        let index = occurrences.indexOf(occurrence)!
                        occurrences.removeAtIndex(index)
                        break
                    }
                }
            }
        }

        return occurrences.sort { $0.isBeforeOrSameWith($1) }
    }

    public func occurrencesBetween(date date: NSDate, andDate otherDate: NSDate, endlessRecurrenceCount: Int = Generator.endlessRecurrenceCount) -> [NSDate] {
        guard let rrulejs = JavaScriptBridge.rrulejs() else {
            return []
        }

        let beginDate = date.isBeforeOrSameWith(otherDate) ? date : otherDate
        let untilDate = otherDate.isAfterOrSameWith(date) ? otherDate : date
        let beginDateJSON = RRule.ISO8601DateFormatter.stringFromDate(beginDate)
        let untilDateJSON = RRule.ISO8601DateFormatter.stringFromDate(untilDate)

        let ruleJSONString = toJSONString(endlessRecurrenceCount: endlessRecurrenceCount)
        let context = JSContext()
        context.exceptionHandler = { context, exception in
            print("[RRuleSwift] rrule.js error: \(exception)")
        }
        context.evaluateScript(rrulejs)
        context.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard let betweenOccurrences = context.evaluateScript("rule.between(new Date('\(beginDateJSON)'), new Date('\(untilDateJSON)'))").toArray() as? [NSDate] else {
            return []
        }

        var occurrences = betweenOccurrences
        if let rdates = rdate?.dates {
            occurrences.appendContentsOf(rdates)
        }

        if let exdates = exdate?.dates, unit = exdate?.unit {
            for occurrence in occurrences {
                for exdate in exdates {
                    if calendar.isDate(occurrence, equalToDate: exdate, toUnitGranularity: unit) {
                        let index = occurrences.indexOf(occurrence)!
                        occurrences.removeAtIndex(index)
                        break
                    }
                }
            }
        }

        return occurrences.sort { $0.isBeforeOrSameWith($1) }
    }
}
