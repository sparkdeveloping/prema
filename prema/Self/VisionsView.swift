//
//  VisionsView.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/5/23.
//

import Foundation
import SwiftUI

struct VisionsView: View {
    @State var currentTab: String = "visions"
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.safeAreaInsets) var safeAreaInsets
    @StateObject var navigationManager = NavigationManager.shared
    @StateObject var selfManager = SelfManager.shared
    @EnvironmentObject var appearance: AppearanceManager

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Text("Nov")
                            .bold()
                            .foregroundStyle(Color.vibrant)
                            
                    }
                    .buttonPadding(20)
                    .nonVibrantBackground(cornerRadius: 20, colorScheme: colorScheme)
                }
                .topPadding(safeAreaInsets.top)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        CustomSelectorView(selection: $currentTab, strings: ["visions", "tasks"])
                        Spacer()
                    }
                    
                    Text("writing ALL your visions down is proof of expectation")
                        .font(.subheadline)
                        .bold()
                        .roundedFont()
                        .foregroundStyle(.secondary)
                        .horizontalPadding(20)
                    ForEach(selfManager.visions) { vision in
                        VStack(spacing: 20) {
                            HStack {
                                Text("NO PRIORITY YET")
                                    .font(.subheadline.bold())
                                    .roundedFont()
                                Spacer()
                                Label(vision.deadline.formattedDateString, systemImage: "clock.arrow.circlepath")
                                    .font(.subheadline.bold())
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading) {
                            
                                Text(vision.title)
                                    .font(.title2.bold())
                                    .multilineTextAlignment(.leading)
                                Text(vision.category.uppercased())
                                    .font(.title3)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .verticalPadding()
                            if !vision.tasks.isEmpty {
                                VStack {
                                    HStack {
                                        ForEach(vision.tasks) { task in
                                        Capsule()
                                                .fill(task.completionTimestamp == nil ? .secondary:AppearanceManager.shared.currentTheme.vibrantColors[0])
                                                .frame(height: 4)
                                        }
                                    }
                                    HStack {
                                        ForEach(vision.visionaries) { visionary in
                                            ProfileImageView(avatars: visionary.avatars)
                                                .frame(width: 40, height: 40)
                                        }
                                        Spacer()
                                        let completed = vision.tasks.filter({$0.completionTimestamp != nil }).count
                                        
                                        Text("\(completed)/\(vision.tasks.count)")
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
                    }
                }
                .padding(.top, Double.blobHeight - safeAreaInsets.top)
                .horizontalPadding()
            }
        }
        .ignoresSafeArea()
       
    }
}

struct NewVisionView: View {
    @EnvironmentObject var appearance: AppearanceManager
    @EnvironmentObject var selfManager: SelfManager
    @StateObject var navigation = NavigationManager.shared
    @Environment (\.colorScheme) var colorScheme
    @State var id: String = ""
    @State var title: String = ""
    @State var category: String?
    @State var privacy: String?
    @State var deadline: Date = Date.now
    @State var visionaries: [Profile] = []
    @State var timestamps: [Timestamp] = []
    @State var completionTimestamp: Timestamp? = nil
    @State var showProfilePicker = false
    var buttonEnabled: Bool {
        return !title.isEmpty && !(category == nil) && !visionaries.isEmpty && !(privacy == nil)
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
                        CustomPickerView(selection: $category, categories: ["spiritual", "financial", "family", "relationships", "professional", "other"])
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
                                .padding(8)
                                .nonVibrantSecondaryBackground(cornerRadius: 8, colorScheme: colorScheme)
                            Button {
                                showProfilePicker.toggle()
                            } label : {
                                HStack {
                                    if visionaries.isEmpty {
                                        Text("Who is this vision for")
                                    } else {
                                        Text(visionaries.map { $0.fullName }.joined(separator: ", ") )
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
                            
                            let vision = Vision(id: "", title: title, category: category ?? "", privacy: Privacy(rawValue: privacy ?? "") ?? .private, comments: [], deadline: deadline.timeIntervalSince1970, visionaries: visionaries, accepts: [], timestamps: [], completionTimestamp: nil, tasks: [])
                          
                            selfManager.createVision(vision: vision) {
                                navigation.showNewVision.toggle()
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
    @State var recursion: String?
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
                        CustomPickerView(selection: $recursion, imageName: "Recursion", selectTitle: "Recursion", categories: ["never", "daily", "weekly", "biweekly", "monthly"])
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
                                        Text("Who is this vision for")
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
                            let task = Task(id: "", title: title, start: start.timeIntervalSince1970, end: end.timeIntervalSince1970, responsibles: responsibles, timestamps: [], completionTimestamp: nil, recursion: Recursion(rawValue: recursion ?? "") ?? .never)
                            withAnimation(.spring()) {
                                selfManager.createTask(vision: vision, task: task) {
                                    navigation.showNewTaskVision = nil
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
            ProfileSearchView(preloadTitle: "Visionaries", preload: vision.visionaries) { profiles in
                responsibles = profiles
            }
        }
    }
}

struct CustomSelectorView: View {
    @Binding var selection: String
    @Environment (\.colorScheme) var colorScheme
    var strings: [String]
    @Namespace var namespace
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(strings, id: \.self) { string in
                    Button {
                        withAnimation(.spring) {
                            selection = string
                        }
                    } label: {
                        Text(string)
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
        .scrollIndicators(.hidden)
    }
}


extension Double {
    var formattedDateString: String {
        let dateFormatter = DateFormatter()
        
        let currentDate = Date()
        let inputDate = Date(timeIntervalSince1970: self)
        
        if Calendar.current.isDateInToday(inputDate) {
            dateFormatter.dateFormat = "'Today'"
        } else if Calendar.current.isDateInTomorrow(inputDate) {
            dateFormatter.dateFormat = "'Tomorrow'"
        } else if Calendar.current.isDateInYesterday(inputDate) {
            dateFormatter.dateFormat = "'Yesterday'"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
        }

        let formattedDate = dateFormatter.string(from: inputDate)
        return formattedDate
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
                                .frame(height: 4)
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
                            Text(vision.deadline.formattedDateString)
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
                      
                            TabView(selection: $selection) {
                                tasksView
                                    .tag("tasks")
                                Color.clear
                                    .tag("comments")
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                     
                    }
                    .padding(10)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadii: .init(topLeading: 30, bottomLeading: 0, bottomTrailing: 0, topTrailing: 30), style: .continuous))
                }
            }
            .topPadding(Double.blobHeight - safeAreaInsets.top)
            .horizontalPadding()
        
        .ignoresSafeArea()
        .nonVibrantSecondaryBackground(cornerRadius: 0, colorScheme: colorScheme)
        .ignoresSafeArea()
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
        ScrollView {
            VStack {
                ForEach(vision.tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                            Text("Due: " + "\(task.end.formattedDateString)")
                        }
                        Spacer()
                        HStack(spacing: 20) {
                            Image(systemName: "trash.fill")
                                .font(.title3)
                                .contentShape(.rect)
                                .onTapGesture {
                                    if let profile = AccountManager.shared.currentProfile {
                                        withAnimation(.spring()) {
                                            var tasks = vision.tasks
                                            
                                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                                vision.tasks.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            Text(task.completionTimestamp == nil ? "mark complete":"completed")
                                .buttonPadding()
                                .font(.title3)
                                .foregroundStyle(task.completionTimestamp != nil ? .primary:.secondary)
                                .background {
                                    if task.completionTimestamp == nil {
                                        Color.clear.nonVibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
                                    } else {
                                        Color.clear.vibrantBackground(cornerRadius: 12, colorScheme: colorScheme)
                                    }
                                }
                                .contentShape(.rect)
                                .onTapGesture {
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
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                }
            }
        }
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
    }
    
}
