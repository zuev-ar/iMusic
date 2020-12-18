//
//  Library.swift
//  iMusic
//
//  Created by Arkasha Zuev on 18.12.2020.
//

import SwiftUI

struct Library: View {
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack (spacing: 20) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9098039216, green: 0.2705882353, blue: 0.5882352941, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9654909968, green: 0.960685432, blue: 0.9692009091, alpha: 1)))
                                .cornerRadius(10)
                        })
                        Button(action: {
                            
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
                    LibraryCell()
                }
            }
        }
        .navigationTitle("Library")
    }
}

struct LibraryCell: View {
    var body: some View {
        HStack {
            Image("Image").resizable().frame(width: 60, height: 60).cornerRadius(2)
            VStack {
                Text("Track name")
                Text("Artist name")
            }
        }
    }
}

//struct Library_Previews: PreviewProvider {
//    static var previews: some View {
//        Library()
//    }
//}
