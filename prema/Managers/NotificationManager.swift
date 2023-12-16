//
//  Camera_ViewModel.swift
//  Elixer
//
//  Created by Denzel Anderson on 5/29/22.
//

import Foundation
import UserNotifications
import CoreLocation

enum NotificationManagerConstants {
  static let timeBasedNotificationThreadId =
    "TimeBasedNotificationThreadId"
  static let calendarBasedNotificationThreadId =
    "CalendarBasedNotificationThreadId"
  static let locationBasedNotificationThreadId =
    "LocationBasedNotificationThreadId"
}

class NotificationManager: ObservableObject {
  static let shared = NotificationManager()
  @Published var settings: UNNotificationSettings?
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

  func requestAuthorization(completion: @escaping  (Bool) -> Void) {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
        self.fetchNotificationSettings()
        completion(granted)
      }
  }

  func fetchNotificationSettings() {
    // 1
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      // 2
      DispatchQueue.main.async {
        self.settings = settings
      }
    }
  }

  func removeScheduledNotification(task: Task) {
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(withIdentifiers: [task.id])
  }

    func scheduleNotification(task: Task) {
        for i in (Array(0..<2)) {
            
            var isReminder: Bool = i == 0
            
            var trigger: UNNotificationTrigger?
            
            let content = UNMutableNotificationContent()
            content.title = task.title + (isReminder ? " in 15 minutes":" now")
            content.body = isReminder ? "Please get ready to start :)":"Please get started (Click me to let me to record it)"
            
            content.categoryIdentifier = isReminder ? "TaskReminderCategory":"TaskCategory"
            let taskData = try? JSONEncoder().encode(task)
            if let taskData = taskData {
                content.userInfo = ["data": task.dictionary]
            }
            
            
            print("the task is: \(task.title) - \(task.start) - \(task.start.date)")
            var dateComp: Set<Calendar.Component> = []
            switch task.recursion {
            case .hourly:
                dateComp = [.minute]
            case .daily:
                dateComp = [.hour, .minute]
            case .weekly:
                dateComp = [.hour, .minute, .day]
            case .monthly:
                dateComp = [.hour, .minute, .day, .weekday]
            case .yearly:
                dateComp = [.hour, .minute, .day, .weekday, .month]
            case .never:
                dateComp = [.hour, .minute, .day, .weekday, .month, .year]
            }
            
            let fromReminderDate = task.start - 900
            let fromDate = task.start
            
            let date = isReminder ? fromReminderDate:fromDate
            
            trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    dateComp,
                    from: date.date),
                repeats: task.recursion != .never)
            if let trigger = trigger {
                let request = UNNotificationRequest(
                    identifier: task.id,
                    content: content,
                    trigger: trigger)
                // 5
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
  // 1
    /*
  func scheduleNotification(task: Task) {
    // 2
      guard task.
    let content = UNMutableNotificationContent()
      content.title = "Task Reminder🤍"
      content.body = task.title
    content.categoryIdentifier = "TaskCategory"
    let taskData = try? JSONEncoder().encode(task)
    if let taskData = taskData {
        content.userInfo = ["Task": task.dictionary]
    }

    // 3
    var trigger: UNNotificationTrigger?
//    switch task.reminder.reminderType {
//    case .time:
//      if let timeInterval = task.reminder.timeInterval {
//        trigger = UNTimeIntervalNotificationTrigger(
//          timeInterval: timeInterval,
//          repeats: task.reminder.repeats)
//      }
//      content.threadIdentifier =
//        NotificationManagerConstants.timeBasedNotificationThreadId
//    case .calendar:
//        if let date = task.end.date {
        
        var components: Set<Calendar.Component> = []
        
        switch task.recursion {
            
        case .never:
            components = []
        case .daily:
            components = [.hour, .minute]
        case .weekly:
            components = [.hour, .minute, .day]
        case .monthly:
            components = [.hour, .minute, .month, .day]
        case .yearly:
            components = [.year, .hour, .minute, .month, .day]
        }
      
      trigger = UNCalendarNotificationTrigger(
        dateMatching: Calendar.current.dateComponents(
            components,
            from: task.start.date),
        repeats: task.recursion != .never)
      
      
      content.threadIdentifier =
      NotificationManagerConstants.timeBasedNotificationThreadId//calendarBasedNotificationThreadId
      //    case .location:
      //      // 1
      //      guard CLLocationManager().authorizationStatus == .authorizedWhenInUse else {
      //        return
      //      }
//      // 2
//      if let location = task.reminder.location {
//        // 3
//        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//        let region = CLCircularRegion(center: center, radius: location.radius, identifier: task.id)
//        trigger = UNLocationNotificationTrigger(region: region, repeats: task.reminder.repeats)
//      }
//      content.threadIdentifier =
//        NotificationManagerConstants.locationBasedNotificationThreadId
//    }

    // 4
    if let trigger = trigger {
      let request = UNNotificationRequest(
        identifier: task.id,
        content: content,
        trigger: trigger)
      // 5
      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("notification added error: \(error.localizedDescription)")
            return
        }
          print("notification added success - \(task.title)")
          
      }
    }
  }
     */
}
