//
//  VideoView.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-03.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var currentVideoUrlObject: videoUrlObject
    @State private var player: AVPlayer?
    
    var body: some View {
        HStack {
            VideoPlayer(player: player)
            .onAppear() {
                guard let url = URL(string: currentVideoUrlObject.currentVideoUrl) else {
                    return
                }
                let player = AVPlayer(url: url)
                self.player = player
                player.play()
            }
            .frame(width: 1920, height: 1080, alignment: .bottomLeading)
        }
        .onExitCommand() {
            currentVideoUrlObject.currentVideoUrl = ""
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
