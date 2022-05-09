//
//  ContentView.swift
//  EyevinnTV
//
//  Created by Sebastian Ljungman on 2022-05-03.
//

import SwiftUI
import SWXMLHash

class videoUrlObject: ObservableObject {
    @Published var currentVideoUrl = ""
    @Published var currentVideoTitle = ""
}

struct ContentView: View {
    @State var videoItems = [Item]()
    @State var liveVideoItems = [Item]()
    @StateObject var outerVideoUrlObject = videoUrlObject()
    
    private var vodXml: String = (Bundle.main.infoDictionary?["VOD_XML"] as! String).replacingOccurrences(of: "\\", with: "")
    private var liveXml: String = (Bundle.main.infoDictionary?["LIVE_XML"] as! String).replacingOccurrences(of: "\\", with: "")
    
    var body: some View {
        NavigationView {
            if outerVideoUrlObject.currentVideoUrl == "" {
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
                                        outerVideoUrlObject.currentVideoUrl = item.videoUrl
                                        outerVideoUrlObject.currentVideoTitle = item.title
                                        print(item.videoUrl) } label: {
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
                            ForEach(liveVideoItems) { item in
                                VStack {
                                    Button {
                                        outerVideoUrlObject.currentVideoUrl = item.videoUrl
                                        outerVideoUrlObject.currentVideoTitle = item.title
                                        print(item.videoUrl) } label: {
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
                    .focusSection()
                }
            } else {
                VideoView(innerUrlObject: outerVideoUrlObject)
            }
        }
        .onAppear() {
            loadData()
        }
    }
    
    func parseXML(feed: String, isLive: Bool) {
        let xml = SWXMLHash.parse(feed)
        
        for elem in xml["feed"]["entry"].all
        {
            let item = Item()
            item.title = elem["title"].element!.text
            item.id = elem["id"].element!.text
            item.videoUrl = elem["link"].element!.text
            isLive ? liveVideoItems.append(item) : videoItems.append(item)
        }
    }
    
    func loadData() {
        [vodXml, liveXml].forEach {
            let isLive = $0 == liveXml
            
            if $0.prefix(7) == "file://" || $0.prefix(7) == "http://" || $0.prefix(8) == "https://" {
                let url = NSURL(string: $0)
                let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
                    if data != nil {
                        let feed = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                        parseXML(feed: feed, isLive: isLive)
                    }
                }
                task.resume()
            } else {
                let filenameInBundle = Bundle.main.path(forResource: $0, ofType: "xml")
                let data = NSData(contentsOfFile: filenameInBundle!)
                
                if data != nil {
                    let feed = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
                    parseXML(feed: feed, isLive: isLive)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
