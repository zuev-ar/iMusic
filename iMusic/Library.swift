//
//  Library.swift
//  iMusic
//
//  Created by Arkasha Zuev on 18.12.2020.
//

import SwiftUI
import URLImage

struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack (spacing: 20) {
                        Button(action: {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailController(viewModel: self.track)
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9098039216, green: 0.2705882353, blue: 0.5882352941, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9654909968, green: 0.960685432, blue: 0.9692009091, alpha: 1)))
                                .cornerRadius(10)
                        })
                        Button(action: {
                            self.tracks = UserDefaults.standard.savedTracks()
                        }, label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9098039216, green: 0.2705882353, blue: 0.5882352941, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9647058824, green: 0.9607843137, blue: 0.968627451, alpha: 1)))
                                .cornerRadius(10)
                        })
                    }
                }.padding().frame(height: 50)
                Divider().padding(.leading).padding(.trailing).padding(.top)
                
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(
                            LongPressGesture()
                                .onEnded { _ in
                                    self.track = track
                                    self.showingAlert = true
                                }
                                .simultaneously(with: TapGesture()
                                    .onEnded { _ in
                                        let keyWindow = UIApplication.shared.connectedScenes.filter({
                                            $0.activationState == .foregroundActive
                                        }).map({
                                            $0 as? UIWindowScene
                                        }).compactMap ({ $0 }).first?.windows.filter({ $0.isKeyWindow }).first
                                        
                                        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                                        tabBarVC?.trackDetailView.delegate = self
                                        
                                        self.track = track
                                        self.tabBarDelegate?.maximizeTrackDetailController(viewModel: track)
                                    }))
                    }
                    .onDelete(perform: delete)
                }
                .navigationTitle("Library")
            }
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(title: Text("Are you sure you want to delete this track?"), buttons: [.destructive(Text("Delete"), action: {
                    self.delete(track: self.track)
                }), .cancel()])
            })
        }
    }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
}

struct LibraryCell: View {
    
    var cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(url: URL(string: cell.iconUrlString ?? "")!,
                     content: { image in
                         image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(2)
                     })
            VStack (alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
            }
        }
    }
    
}

extension Library: TrackMovingDelegate {
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        
        let index = tracks.firstIndex(of: track)
        
        guard let myIndex = index else { return nil }
        
        var nextTrack: SearchViewModel.Cell
        
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        
        self.track = nextTrack
        return nextTrack
        
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
       
        let index = tracks.firstIndex(of: track)
        
        guard let myIndex = index else { return nil }
        
        var nextTrack: SearchViewModel.Cell
        
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        
        self.track = nextTrack
        return nextTrack
        
    }
    
}

//struct Library_Previews: PreviewProvider {
//    static var previews: some View {
//        Library()
//    }
//}
