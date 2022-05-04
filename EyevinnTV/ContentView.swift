//
//  ContentView.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-03.
//

import SwiftUI
import SWXMLHash

class videoURLObject: ObservableObject {
    @Published var currentVideoURL = ""
    @Published var currentVideoTitle = ""
}

struct ContentView: View {
    @State var videoItems = [Item]()
    @StateObject var outerVideoURLObject = videoURLObject()
    
    var body: some View {
        NavigationView {
            if outerVideoURLObject.currentVideoURL == "" {
                VStack{
                    Image("eyevinn-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200, alignment: .center)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(videoItems) { item in
                                VStack {
                                    Button {
                                        outerVideoURLObject.currentVideoURL = item.videoURL
                                        outerVideoURLObject.currentVideoTitle = item.title
                                        print(item.videoURL) } label: {
                                            VStack {
                                                Image(systemName: "play.tv")
                                                    .font(.system(size: 100))
                                                Text("\(item.title)")
                                                    .bold()
                                            }
                                            .frame(width: 550, height: 250)
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            VStack {
                                Button {
                                    outerVideoURLObject.currentVideoURL = "https://d2fz24s2fts31b.cloudfront.net/out/v1/6484d7c664924b77893f9b4f63080e5d/manifest.m3u8"
                                    outerVideoURLObject.currentVideoTitle = "HLS LIVE"
                                } label: {
                                    VStack {
                                        Image(systemName: "play.tv")
                                            .font(.system(size: 100))
                                        Text("HLS LIVE")
                                            .bold()
                                    }
                                    .frame(width: 550, height: 250)
                                }
                            }
                            
                            VStack {
                                Button {
                                    outerVideoURLObject.currentVideoURL = "https://edfaeed9c7154a20828a30a26878ade0.mediatailor.eu-west-1.amazonaws.com/v1/master/1b8a07d9a44fe90e52d5698704c72270d177ae74/AdTest/master.m3u8"
                                    outerVideoURLObject.currentVideoTitle = "HLS LIVE SSAI"
                                } label: {
                                    VStack {
                                        Image(systemName: "play.tv")
                                            .font(.system(size: 100))
                                        Text("HLS LIVE SSAI")
                                            .bold()
                                    }
                                    .frame(width: 550, height: 250)
                                }
                            }
                        }
                        .padding()
                    }
                    .focusSection()
                }
            } else {
                VideoView(innerURLObject: outerVideoURLObject)
            }
        }
        .onAppear() {
            loadData()
        }
    }
    
    func loadData() {
        let url = NSURL(string: "https://testcontent.mrss.eyevinn.technology/")
        
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            if data != nil
            {
                let feed=NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                let xml = SWXMLHash.parse(feed)
                
                for elem in xml["feed"]["entry"].all
                {
                    let item = Item()
                    item.title = elem["title"].element!.text
                    item.id = elem["id"].element!.text
                    item.videoURL = elem["link"].element!.text
                    videoItems.append(item)
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
