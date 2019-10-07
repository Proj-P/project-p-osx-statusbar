//
//  DateFormatter.swift
//  Statusbar
//
//  Created by Erik de Groot on 07/10/2019.
//  Copyright © 2019 Tjuna. All rights reserved.
//

import Foundation

let formatter = DateFormatter()

func dateFromString(string: String) -> Date {
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    return formatter.date(from: string)!
}

extension String {
    var toDate: Date {
        return dateFromString(string: self)
    }
}

extension Date {
    func localString(dateStyle: DateFormatter.Style = .medium,
      timeStyle: DateFormatter.Style = .medium) -> String {
        return DateFormatter.localizedString(
          from: self,
          dateStyle: dateStyle,
          timeStyle: timeStyle)
    }

    var midnight: Date {
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: self)
    }
}
