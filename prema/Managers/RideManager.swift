//
//  RideManager.swift
//  prema
//
//  Created by Denzel Nyatsanza on 11/22/23.
//

import MapKit
import SwiftUI
import MapItemPicker

struct CustomAnnotation: Identifiable {
    var id: String = UUID().uuidString
    var item: MapItem
}

class RideManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var search = ""
    @Published var searchResults: [MapItem] = []
    @Published var departure: MapItem?
    @Published var destinations: [MapItem] = []
    
    var destinationsAnnotations: [CustomAnnotation] {
        return destinations.map { .init(item: $0 ) }
    }
    
    func search(coordinate: CLLocationCoordinate2D? = nil) async {
        
        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = search
        mapKitRequest.resultTypes = .pointOfInterest
        if let coordinate {
            mapKitRequest.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
        }
        let search = MKLocalSearch(request: mapKitRequest)
        do {
            let response = try await search.start()
            withAnimation(.spring()) {
                searchResults = response.mapItems.prefix(5).compactMap { mapItem in
                    return .init(name: mapItem.name ?? "Unknown Location", location: mapItem.placemark.coordinate)
                }
            }
        } catch {}
    }
}
