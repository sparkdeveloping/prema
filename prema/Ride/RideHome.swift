import SwiftUI
import MapItemPicker
import MapKit

extension RideView {
    struct RideHome: View {
        @StateObject var ride: RideManager = .init()
        @StateObject var locationManager = LocationManager()
        @Environment (\.safeAreaInsets) var safeAreaInsets
        @State private var route: MKRoute?
        @State private var travelTime: String?
        private let gradient = LinearGradient(colors: AppearanceManager.shared.currentTheme.vibrantColors, startPoint: .leading, endPoint: .trailing)
        private let stroke = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        @State private var cameraPosition: MapCameraPosition = .automatic

        @State var selected: MapItem?
        
        var body: some View {
            ZStack {
                Map(position: $cameraPosition, selection: $selected) {
                                   ForEach(ride.destinations, id: \.self) { wp in
                                       Annotation("Waypoint", coordinate: wp.location) {
                                          
                                           Circle().fill(.blue)
                                               .frame(width: 40, height: 40)
                                       }//annotation
                                   }//for each
                                   .annotationTitles(.hidden)
                               
                    if let route {
                        MapPolyline(route.polyline)
                        //                        .stroke(.blue, lineWidth: 8)
                            .stroke(gradient, style: stroke)
                    }
                }
                .overlay(alignment: .bottom, content: {
                    HStack {
                        if let travelTime {
                            Text("Travel time: \(travelTime)")
                                .padding()
                                .font(.headline)
                                .foregroundStyle(.black)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                        }
                    }
                })
                .onAppear(perform: {
                    fetchRouteFrom(.empireStateBuilding, to: .columbiaUniversity)
                })
                VStack {
                    LocationSearch()
                        .environmentObject(ride)
                    Spacer()
                }
                .ignoresSafeArea()
                .topPadding(Double.blobHeight - safeAreaInsets.top)
            }
        }
    }
}

struct LocationSearch: View {
    
    @EnvironmentObject var ride: RideManager
    @Environment (\.colorScheme) var colorScheme
    @FocusState var startText: Bool
    @FocusState var endText: Bool
    
    var body: some View {
        VStack {
            VStack {
                if !endText {
                    if ride.departure == nil {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Pickup Location", text: $ride.search)
                                .autocorrectionDisabled()
                                .focused($startText)
                                .overlay(alignment: .trailing) {
                                    Text(startText ? "true":"false")
                                }
                        }
                    }
                    Divider()
                        .horizontalPadding()
                        .verticalPadding()
                }
                if !startText {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Add Destination(s)", text: $ride.search)
                            .autocorrectionDisabled()
                            .focused($endText)
                            .overlay(alignment: .trailing) {
                                Text(endText ? "true":"false")
                            }
                    }
                    .onChange(of: ride.search) { _, _ in
                        SwiftUI.Task {
                            await ride.search()
                        }
                    }
                    
                }
                
                
                ForEach((startText || endText) ? ride.searchResults:[], id: \.self) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Image(systemName: "plus")
                            .font(.title3.bold())
                    }
                    .padding(10)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if startText {
                                ride.departure = item
                            } else {
                                ride.destinations.append(item)
                            }
                        }
                        withAnimation(.spring()) {
                            startText = false
                            endText = false
                        }
                    }
                }
            }
            .padding(10)
            .nonVibrantBackground(cornerRadius: 17, colorScheme: colorScheme)
            .onChange(of: startText) { old, new in
                if old == true && new == false {
                    withAnimation(.spring()) {
                        ride.search = ""
                        ride.searchResults.removeAll()
                    }
                }
            }
            .onChange(of: endText) { old, new in
                if old == true && new == false {
                    withAnimation(.spring()) {
                        ride.search = ""
                        ride.searchResults.removeAll()
                    }
                }
            }
            VStack {
                if let departure = ride.departure {
                    HStack {
                        Text(departure.name)
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    ride.departure = nil
                                }
                                withAnimation(.spring()) {
                                    startText = false
                                    endText = false
                                }
                            }
                    }
                }
                if !ride.destinations.isEmpty {
                    
                    ForEach(ride.destinations, id: \.self) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                                .onTapGesture {
                                    if let index = ride.destinations.firstIndex(where: {$0.name == $0.name }) {
                                        withAnimation(.spring()) {
                                            ride.destinations.remove(at: index)
                                        }
                                    }
                                    withAnimation(.spring()) {
                                        startText = false
                                        endText = false
                                    }
                                }
                        }
                        .padding(10)
                    }
                }
            }
            .padding(10)
            .nonVibrantBackground(cornerRadius: 17, colorScheme: colorScheme)
        }
        .padding()
    }
}

extension RideView.RideHome {
    
    private func fetchRouteFrom(_ source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        SwiftUI.Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            getTravelTime()
        }
    }
    
    private func getTravelTime() {
        guard let route else { return }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }
}

extension CLLocationCoordinate2D {
    static let weequahicPark = CLLocationCoordinate2D(latitude: 40.7063, longitude: -74.1973)
    static let empireStateBuilding = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
    static let columbiaUniversity = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
}
