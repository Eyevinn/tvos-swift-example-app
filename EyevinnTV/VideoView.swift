//
//  VideoView.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-03.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var innerURLObject: videoURLObject
    @State private var player: AVPlayer?
    
    var body: some View {
        HStack {
            VideoPlayer(player: player, videoOverlay: {
                //Doesn't toggle correctly
                if player?.timeControlStatus != AVPlayer.TimeControlStatus.paused {
                    Spacer()
                    Text(innerURLObject.currentVideoTitle)
                }
                
            })
            .onAppear() {
                guard let url = URL(string: innerURLObject.currentVideoURL) else {
                    return
                }
                let player = AVPlayer(url: url)
                self.player = player
                player.play()
                print(player.timeControlStatus)
            }
            .frame(width: 1920, height: 1080, alignment: .bottomLeading)
            
        }
        .onExitCommand() {
            innerURLObject.currentVideoURL = ""
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
