//
//  VisionsView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Lottie
import Foundation
import SwiftUI

struct VisionsView: View {
    
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @StateObject var navigationManager = NavigationManager.shared
    @StateObject var selfManager = SelfManager.shared
    @EnvironmentObject var appearance: AppearanceManager

    var body: some View {
        ZStack {
           
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        CustomSelectorView(selection: $selfManager.selection, strings: ["my visions", "tasks", "explore", "requests"])
                        Spacer()
                    }
                    if !selfManager.visions.isEmpty {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Visions")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                Text("\(selfManager.visions.filter({$0.completionTimestamp == nil }).count)/\(selfManager.visions.count)")
                            }
                            .frame(maxWidth: .infinity)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Tasks")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                Text("\(selfManager.visions.map({$0.tasks.filter({$0.completionTimestamp == nil })}).count)/\(selfManager.visions.flatMap({$0.tasks}).count)")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .verticalPadding()
                    }
                    if selfManager.selection != "tasks" {
                        visionsView
                    } else {
                        tasksView
                    }
//                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                }
                .padding(.top, Double.blobHeight - safeAreaInsets.top)
                .horizontalPadding()
                .bottomPadding(safeAreaInsets.bottom + 80)
            }
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Today is")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                            .roundedFont()
                        
                        Text(Date.now.timeIntervalSince1970.formattedDateString(format: "EEEE, MMM d"))
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .roundedFont()
                    }
                    .buttonPadding(20)
//                    .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                }
                .topPadding(safeAreaInsets.top)
                Spacer()
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea()
       
    }
    
    var visionsView: some View {
        GeometryReader {
            let size = $0.size
            VStack(alignment: .leading) {
                if selfManager.visions.isEmpty {
                    VStack {
                        LottieView(name: "Empty")
                            .frame(width: size.width / 4, height: size.width / 4)
                            .verticalPadding(40)
                        Text("You do not have any Visions yet :(")
                            .font(.subheadline.bold())
                            .roundedFont()
                            .foregroundStyle(.secondary)
                        Button {
                            withAnimation(.spring()) {
                                navigationManager.showNewVision = true
                            }
                        } label: {
                            Text("Create My First Vision")
                                .bold()
                                .roundedFont()
                                .foregroundStyle(.white)
                                .buttonPadding()
                                .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
                            
                        }
                        .topPadding(20)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack {
                        Text("writing ALL your visions down is proof of expectation")
                            .font(.subheadline)
                            .bold()
                            .roundedFont()
                            .foregroundStyle(.secondary)
                    }
                    .horizontalPadding(20)
                    ForEach(selfManager.visions) { vision in
                        VisionCellView(vision: vision)
                    }
                }
            }
        }
        
    }
    
    var tasksView: some View {
        VStack {
            ForEach(groupedTasks, id: \.0) { sectionTitle, sectionTasks in
                TaskSectionView(sectionTitle: sectionTitle, tasks: sectionTasks)
                    .padding(.vertical, 8)
            }
            
        }
    }
    
    private var groupedTasks: [(String, [Task])] {
        let groupedDictionary = Dictionary(grouping: selfManager.visions.flatMap { $0.tasks }) { task in
            getSectionTitle(for: task.end.date)
            }

            let sortedGroups = groupedDictionary.sorted { $0.key < $1.key }

            return sortedGroups
        }

        private func getSectionTitle(for date: Date) -> String {
            let calendar = Calendar.current
            let currentDate = Date()

            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInTomorrow(date) {
                return "Tomorrow"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMM d"
                return dateFormatter.string(from: date)
            }
        }
}

struct TaskSectionView: View {
    let sectionTitle: String
    let tasks: [Task]

    var body: some View {
        VStack(alignment: .leading) {
            Text(sectionTitle)
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(tasks) { task in
                TaskCellView(task: task)
            }
        }
    }
}

struct VisionCellView: View {
    @ObservedObject var vision: Vision
    @State var currentTab: String = "visions"
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @StateObject var navigationManager = NavigationManager.shared
    @StateObject var selfManager = SelfManager.shared
    @EnvironmentObject var appearance: AppearanceManager
    
    var body: some View {
        
        VStack(spacing: 20) {
            HStack {
                Label("Deadline: " + vision.deadline.formattedDateString(showTime: true), systemImage: "clock.arrow.circlepath")
                    .font(.subheadline.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .buttonPadding()
                    .background(vision.priorityColor.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 7, style: .continuous))
                Spacer()
                Text(vision.category.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
               
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(vision.title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
           
            }
            .verticalPadding(7)
            
            if let task = vision.tasks.sorted(by: { $0.end > $1.end }).filter({$0.completionTimestamp == nil}).first {
                VStack(alignment: .leading) {
                    Text("Next task:")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    TaskCellView(showSide: false, task: task)
                        .nonVibrantBackground(cornerRadius: 17, colorScheme: colorScheme)
                        .transition(.scale)
                }
            }
            
            if !vision.tasks.isEmpty {
                VStack {
                    HStack {
                        ForEach(vision.tasks) { task in
                            Capsule()
                                .fill(task.completionTimestamp == nil ? .secondary:AppearanceManager.shared.currentTheme.vibrantColors[0])
                                .frame(height: 8)
                        }
                    }
                    HStack {
                        ForEach(vision.visionaries) { visionary in
                            ProfileImageView(avatars: visionary.avatars)
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                        let completed = vision.tasks.filter({$0.completionTimestamp != nil }).count
                        Text("\(completed)/\(vision.tasks.count) COMPLETED")
                            .font(.caption2.bold())
                    }
                }
            } else {
                VStack {
                    
                    Text("No set tasks yet :(")
                        .font(.subheadline.italic())
                        .verticalPadding()
                    
                    Button {
                        withAnimation(.spring()) {
                            navigationManager.showNewTaskVision = vision
                        }
                    } label: {
                        Text("Create New Task")
                            .bold()
                            .roundedFont()
                            .frame(maxWidth: .infinity)
                            .buttonPadding()
                            .vibrantBackground(cornerRadius: 17, colorScheme: colorScheme)
                    }
                    .foregroundStyle(.primary)
                    
                }
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .clipShape(.rect(cornerRadius: 20, style: .continuous))
                .padding(-10)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            withAnimation(.spring()) {
                navigationManager.path.append(vision)
            }
        }
        .contextMenu {
            Button {
                selfManager.deleteVision(vision)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            .foregroundStyle(.red)
        }
    }
}

struct NewVisionView: View {
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var selfManager: SelfManager
    @StateObject var navigation = NavigationManager.shared
    @Environment (\.colorScheme) var colorScheme
    @State var id: String = ""
    @State var title: String = ""
    @State var category: String = ""
    @State var privacy: String = ""
    @State var deadline: Date = Date.now
    @State var visionaries: [Profile] = []
    @State var timestamps: [Timestamp] = []
    @State var completionTimestamp: Timestamp? = nil
    @State var showProfilePicker = false
    var buttonEnabled: Bool {
        return !title.isEmpty && !(category.isEmpty) && !visionaries.isEmpty && !(privacy.isEmpty)
    }
    
    var body: some View {
 
        ZStack {
            if appearance.isLoading {
                SpinnerView()
                    .frame(width: 80, height: 80)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("New Vision")
                                .font(.largeTitle.bold())
                                .roundedFont()
                            Text("We will make this quick!")
                                .font(.caption)
                        }
                        Spacer()
                        DismissButton() {
                            withAnimation(.spring()) {
                                navigation.showNewVision = false
                            }
                        }
                    }
                    VStack {
                        CustomTextField(text: $title, imageName: "Badge", placeHolder: "What is the end result for this goal?")
                        Divider()
                            .padding(10)
                        CustomPickerView(selection: $category, selectTitle: "Select Category", categories: ["spiritual", "financial", "family", "relationships", "professional", "other"])
                        Divider()
                            .padding(10)
                        CustomPickerView(selection: $privacy, imageName: "Privacy", selectTitle: "Privacy", categories: ["public", "direct", "private"])
                        Divider()
                            .padding(10)
                        HStack {
                            Image("Calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            DatePicker("Deadline", selection: $deadline, in: Date.now..., displayedComponents: .date)
                        }
                        Divider()
                            .padding(10)
                        HStack {
                            Image("Visionary")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(visionaries.isEmpty ? .secondary:.primary)

                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            Button {
                                showProfilePicker.toggle()
                            } label : {
                                HStack {
                                    if visionaries.isEmpty {
                                        Text("Who is this vision for?")
                                    } else {
                                        Text(visionaries.map { $0.fullName }.joined(separator: ", ") )
                                    }
                                    Spacer()
                                }
                            }
                            .foregroundStyle(visionaries.isEmpty ? .secondary:.primary)

                        }
                   
                    }
               
                    if !buttonEnabled {
                        Button {} label: {
                            Text("create")
                                .font(.title3.bold())
                                .foregroundStyle(.gray)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .nonVibrantSecondaryBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                        .allowsHitTesting(false)
                    } else {
                        Button {
                            
                            let vision = Vision(id: "", title: title, category: category ?? "", privacy: Privacy(rawValue: privacy ?? "") ?? .private, comments: [], deadline: deadline.timeIntervalSince1970, visionaries: visionaries, accepts: [], requests: [], timestamps: [], completionTimestamp: nil, tasks: [])
                          
                            selfManager.createVision(vision: vision) {
                                navigation.showNewVision.toggle()
                                haptic()
                            }
                            
                        } label: {
                            Text("create")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .vibrantBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                    }
                }
            }
        }
        .padding()
        .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
        .padding()
        .padding(.vertical, 10)
        .sheet(isPresented: $showProfilePicker) {
            ProfileSearchView(preloadTitle: "Your Profiles", preload: AccountManager.shared.currentAccount?.profiles) { profiles in
                visionaries = profiles
            }
        }
    }
}

struct NewTaskView: View {
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var selfManager: SelfManager
    @StateObject var navigation = NavigationManager.shared
    @Environment (\.colorScheme) var colorScheme
    @State var vision: Vision
    @State var title: String = ""
    @State var category: String?
    @State var recursion: String = "never"
    @State var start: Date = Date.now
    @State var end: Date = Date.now
    @State var responsibles: [Profile] = []
    @State var timestamps: [Timestamp] = []
    @State var completionTimestamp: Timestamp? = nil
    @State var showProfilePicker = false
    var buttonEnabled: Bool {
        return !title.isEmpty && !(recursion == nil) && !responsibles.isEmpty
    }
    
    var body: some View {
 
        ZStack {
            if appearance.isLoading {
                SpinnerView()
                    .frame(width: 80, height: 80)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("New Task")
                                .font(.largeTitle.bold())
                                .roundedFont()
                            Text("actions birth results, good job!")
                                .font(.caption)
                        }
                        Spacer()
                        DismissButton() {
                            withAnimation(.spring()) {
                                navigation.showNewTaskVision = nil
                            }
                        }
                    }
                    VStack {
                        CustomTextField(text: $title, imageName: "Badge", placeHolder: "What is the task")
                        Divider()
                            .padding(10)
                        CustomPickerView(selection: $recursion, imageName: "Recursion", selectTitle: "Recursion", categories: Recursion.allCases.map {$0.rawValue})
                        Divider()
                            .padding(10)
                   
                            HStack {
                                Image("Calendar")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(8)
                                    .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                                DatePicker("Start", selection: $start, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                            }
                            HStack {
                                Image("Calendar")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(8)
                                    .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                                DatePicker("End", selection: $end, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                            }
                        
                        Divider()
                            .padding(10)
                        
                        HStack {
                            Image("Visionary")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            Button {
                                showProfilePicker.toggle()
                            } label : {
                                HStack {
                                    if responsibles.isEmpty {
                                        Text("Who is responsible for this task?")
                                    } else {
                                        Text(responsibles.map { $0.fullName }.joined(separator: ", ") )
                                    }
                                    Spacer()
                                }
                            }
                            .foregroundStyle(.primary)

                        }
                   
                    }
               
                    if !buttonEnabled {
                        Button {} label: {
                            Text("create")
                                .font(.title3.bold())
                                .foregroundStyle(.gray)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .nonVibrantSecondaryBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                        .allowsHitTesting(false)
                    } else {
                        
                        Button {
                            let task = Task(id: "", title: title, start: start.timeIntervalSince1970, end: end.timeIntervalSince1970, responsibles: responsibles, timestamps: [], completionTimestamp: nil, recursion: recursion.recursion)
                            withAnimation(.spring()) {
                                selfManager.createTask(vision: vision, task: task) {
                                    navigation.showNewTaskVision = nil
                                    haptic()
                                }
                            }
                        } label: {
                            Text("create")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .buttonPadding(20)
                                .frame(maxWidth: .infinity)
                                .vibrantBackground(cornerRadius: 25, colorScheme: colorScheme)
                        }
                    }
                }
            }
        }
        .padding()
        .nonVibrantBackground(cornerRadius: 30, colorScheme: colorScheme)
        .padding()
        .padding(.vertical, 10)
        .sheet(isPresented: $showProfilePicker) {
            ProfileSearchView(preloadTitle: "Visionaries & Accountability Partners", preload: vision.visionaries) { profiles in
                responsibles = profiles
            }
        }
    }
}

struct CustomSelectorView: View {
    var scrollable: Bool = true
    @Binding var selection: String
    @StateObject var direct = DirectManager.shared
    @StateObject var selfM = SelfManager.shared

    @Environment (\.colorScheme) var colorScheme
    var strings: [String]
    @Namespace var namespace
    var body: some View {
        if scrollable {
            ScrollView(.horizontal) {
                view
            }
            .scrollIndicators(.hidden)
        } else {
            view
        }
    }
    var view: some View {
        HStack {
            ForEach(strings, id: \.self) { string in
                Button {
                    withAnimation(.spring) {
                        selection = string
                    }
                } label: {
                    Text(string == "requests" ? "requests (\(strings.contains("tasks") ? selfM.requests.count: direct.requests.count))":string)
                        .bold()
                        .roundedFont()
                        .buttonPadding(5)
                        .foregroundStyle(selection == string ? .white:Color.primary)
                        .background {
                            if selection == string {
                                Color.clear
                                    .vibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
                                    .matchedGeometryEffect(id: "namespace", in: namespace)
                            }
                        }
                        .contentShape(.rect)
                }
            }
        }
        .padding()
        .verticalPadding()
    }
}


extension Double {
    func formattedDateString(format: String? = nil, showTime: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        dateFormatter2.dateFormat = "h:mm a"
        let time = dateFormatter2.string(from: self.date)
        
        let currentDate = Date()
        let inputDate = Date(timeIntervalSince1970: self)
        
        if Calendar.current.isDateInToday(inputDate) {
            dateFormatter.dateFormat = format == nil ? "'Today'":format
        } else if Calendar.current.isDateInTomorrow(inputDate) {
            dateFormatter.dateFormat = format == nil ? "'Tomorrow'":format
        } else if Calendar.current.isDateInYesterday(inputDate) {
            dateFormatter.dateFormat = format == nil ? "'Yesterday'":format
        } else {
            dateFormatter.dateFormat = format == nil ? "MM/dd/yy":format
        }

        let formattedDate = dateFormatter.string(from: inputDate)
        return (formattedDate + (showTime ? " \(time)":""))
    }
}

struct VisionDetailView: View {
    
    @ObservedObject var vision: Vision
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @State var selection = "tasks"
    @StateObject var navigationManager = NavigationManager.shared

    var priority: String {
        return "LOW"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(vision.title)
                    .font(.largeTitle.bold())
                    .roundedFont()
                VStack {
                    HStack {
                        Spacer()
                        let completed = vision.tasks.filter({$0.completionTimestamp != nil }).count
                        
                        (Text("\(completed)").font(.title.bold()).foregroundStyle(Color.vibrant) + Text(" / \(vision.tasks.count)")).roundedFont()
                    }
                    HStack {
                        ForEach(vision.tasks) { task in
                            Capsule()
                                .fill(task.completionTimestamp == nil ? .secondary:AppearanceManager.shared.currentTheme.vibrantColors[0])
                                .frame(height: 8)
                        }
                    }
                }
                .verticalPadding(20)
                VStack(spacing: 20) {
                    HStack {
                        Label("Priority", systemImage: "exclamationmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack {
                            Text(priority)
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: AppearanceManager.shared.size.width / 2 - 40)
                        
                    }
                    HStack {
                        Label(vision.visionaries.count == 1 ? "Visionary":"Visionaries\(vision.visionaries.count)", systemImage: vision.visionaries.count == 1 ? "person.fill":vision.visionaries.count == 2 ? "person.2.fill":"person.3.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack {
                            Text(vision.visionaries.map {$0.fullName}.joined(separator: ", "))
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: AppearanceManager.shared.size.width / 2 - 40)
                    }
                    HStack {
                        Label("Deadline", systemImage: "timer")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack {
                            Text(vision.deadline.formattedDateString(showTime: true))
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: AppearanceManager.shared.size.width / 2 - 40)
                        
                    }
                    HStack {
                        Label("Privacy", systemImage: "globe")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack {
                            Text(vision.privacy.rawValue)
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: AppearanceManager.shared.size.width / 2 - 40)
                        
                    }
                    .bottomPadding(safeAreaInsets.bottom)
                    
                    VStack {
                        CustomSelectorView(selection: $selection, strings: ["tasks", "comments"])
                        
//                        TabView(selection: $selection) {
                            tasksView
//                                .tag("tasks")
//                            Color.clear
//                                .tag("comments")
//                        }
//                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                    }
//                    .padding(10)
//                    .background(Color.secondary.opacity(0.1))
//                    .clipShape(.rect(cornerRadii: .init(topLeading: 30, bottomLeading: 0, bottomTrailing: 0, topTrailing: 30), style: .continuous))
                }
            }
            .topPadding(Double.blobHeight - safeAreaInsets.top)
            .horizontalPadding()
        }
        .ignoresSafeArea()
        .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            Button {
                withAnimation(.spring()) {
                    navigationManager.showNewTaskVision = vision
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title3.bold())
                    .padding(10)
                    .vibrantBackground(cornerRadius: 14, colorScheme: colorScheme)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2.bold())
                    .foregroundStyle(Color.secondary)
                Divider()
                    .frame(height: 20)
                    .horizontalPadding(4)
                Image(systemName: "trash.fill")
                    .font(.title2.bold())
                    .foregroundStyle(Color.red)

                Divider()
                    .frame(height: 20)
                    .horizontalPadding(4)
                Image(systemName: "paperplane.fill")
                    .font(.title2.bold())
                    .foregroundStyle(AppearanceManager.shared.currentTheme.vibrantColors[0])

            }
            .frame(height: 40)
            .buttonPadding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 20, style: .continuous))
            .padding(.trailing)
            .topPadding(safeAreaInsets.top)
            .ignoresSafeArea()
          
        }
    }
    
    var tasksView: some View {

            VStack {
                ForEach(vision.tasks) { task in
                    TaskCellView(task: task)
                }
            }
        
      
    }
}

struct TaskCellView: View {
    @Environment (\.colorScheme) var colorScheme
    @StateObject var selfManager = SelfManager.shared

var showSide = true
    var vision: Vision {
        SelfManager.shared.visions.first(where: {$0.tasks.contains(where: {$0.id == task.id })})!
    }
    @ObservedObject var task: Task
    
    var background: Color {
        
        var time = task.end
        
        if let t = task.completionTimestamp?.time {
            time = t
        }
        
        guard time < 1 else { return .clear }
        
        let percentage = time / Date.now.timeIntervalSince1970
        
        
        return percentage > 0.75 ? .clear:percentage > 0.50 ? .teal: percentage > 0.45 ? .yellow: percentage > 0.30 ? .orange:.red
    }
    
    var body: some View {
        HStack {
            if showSide {
                if task.completionTimestamp != nil {
                    Image(systemName: "checkmark")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                        .transition(.scale)
                        .padding(14)
                } else {
                    Capsule()
                        .frame(width: 20, height: 4)
                        .padding()
                        .transition(.scale)
                }
            }
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.title3.bold())
                        if let timestamp = task.completionTimestamp {
                            Label("Done " + timestamp.time.formattedDateString(showTime: true), systemImage: "clock.arrow.circlepath")
                                .bold()
                                .foregroundStyle(.orange)
                        } else {
                            Label("Due " + task.end.formattedDateString(showTime: true), systemImage: "clock.arrow.circlepath")
                                .bold()
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Label(task.completionTimestamp == nil ? "complete":"completed", systemImage: task.completionTimestamp == nil ? "circle.dashed":"crown.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(task.completionTimestamp != nil ? .primary:.secondary)
                            .buttonPadding()
                            .background {
                                if task.completionTimestamp == nil {
                                    Color.clear.nonVibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
                                } else {
                                    Color.clear.vibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
                                }
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                haptic()
                                if let profile = AccountManager.shared.currentProfile {
                                    withAnimation(.spring()) {
                                        var tasks = vision.tasks
                                        
                                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                            var task = tasks[index]
                                            task.completionTimestamp = Timestamp(profile: profile, time: Date.now.timeIntervalSince1970)
                                            tasks[index] = task
                                            vision.tasks = tasks
                                        }
                                    }
                                }
                            }
                        
                    }
                }
                .padding(10)
                .background(background.opacity(0.2).overlay(Color.primary.opacity(0.05  )))
                .clipShape(.rect(cornerRadius: 17, style: .continuous))
            .contextMenu {
                Button {
                    if let profile = AccountManager.shared.currentProfile {
                        withAnimation(.spring()) {
                            var tasks = vision.tasks
                            
                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                vision.tasks.remove(at: index)
                            }
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                    
                }
                .foregroundStyle(.red)
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
