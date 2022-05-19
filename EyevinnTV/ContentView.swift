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
    @StateObject var currentVideoUrlObject = videoUrlObject()
    
    private var vodXml: String = ((Bundle.main.infoDictionary?["VOD_XML"] as! String).replacingOccurrences(of: "\\", with: "").prefix(7) == "file://") ?
    "vodContentCopy" : (Bundle.main.infoDictionary?["VOD_XML"] as! String).replacingOccurrences(of: "\\", with: "")
    
    private var liveXml: String = (Bundle.main.infoDictionary?["LIVE_XML"] as! String).replacingOccurrences(of: "\\", with: "").prefix(7) == "file://" ?
    "liveContentCopy" : (Bundle.main.infoDictionary?["LIVE_XML"] as! String).replacingOccurrences(of: "\\", with: "")
    
    var body: some View {
        NavigationView {
            if currentVideoUrlObject.currentVideoUrl == "" {
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
                                        currentVideoUrlObject.currentVideoUrl = item.videoUrl
                                        currentVideoUrlObject.currentVideoTitle = item.title
                                        print(item.videoUrl) } label: {
                                            VStack {
                                                AsyncImage(url: URL(string: item.thumbnailUrl)) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image.resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(maxWidth: 400, maxHeight: 180)
                                                            .cornerRadius(30)
                                                    default:
                                                        Image(systemName: "play.tv")
                                                            .font(.system(size: 150)
                                                            )
                                                    }
                                                }
                                                Spacer()
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
                                        currentVideoUrlObject.currentVideoUrl = item.videoUrl
                                        currentVideoUrlObject.currentVideoTitle = item.title
                                        print(item.videoUrl) } label: {
                                            VStack {
                                                AsyncImage(url: URL(string: item.thumbnailUrl)) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image.resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(maxWidth: 400, maxHeight: 180)
                                                    default:
                                                        Image(systemName: "play.tv")
                                                            .font(.system(size: 150)
                                                            )
                                                    }
                                                }
                                                Spacer()
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
                VideoView(currentVideoUrlObject: currentVideoUrlObject)
            }
        }
        .onAppear() {
            loadData()
        }
    }
    
    func parseXML(feed: String, isLive: Bool) {
        let xml = SWXMLHash.parse(feed)
        
        //For XML feed in correct format (see README)
        for elem in xml["feed"]["entry"].all
        {
            let item = Item()
            item.title = elem["title"].element!.text
            item.id = elem["id"].element!.text
            item.videoUrl = elem["link"].element!.text
            isLive ? liveVideoItems.append(item) : videoItems.append(item)
        }
        
        //For MRSS feed in correct format (see README)
        for elem in xml["rss"]["channel"]["item"].all
        {
            let item = Item()
            item.title = elem["title"].element!.text
            item.id = elem["guid"].element!.text
            item.videoUrl = (elem["media:content"].element?.attribute(by: "url")!.text)!
            item.thumbnailUrl = (elem["media:content"]["media:thumbnail"].element?.attribute(by: "url")!.text)!
            isLive ? liveVideoItems.append(item) : videoItems.append(item)
        }
    }
    
    func loadData() {
        let xmlsIndexed = [vodXml, liveXml].enumerated()
        
        for (index, xml) in xmlsIndexed {
            let isLive = index == 1 ? true : false
            
            if xml.prefix(7) == "http://" || xml.prefix(8) == "https://" {
                let url = NSURL(string: xml)
                let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
                    if data != nil {
                        let feed = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                        parseXML(feed: feed, isLive: isLive)
                    }
                }
                task.resume()
            } else {
                if xml == "" {
                    continue
                }
                let filenameInBundle = Bundle.main.path(forResource: xml, ofType: "xml")
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
