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
                    Text("Select a video to play it")
                        .font(.system(size: 50))
                        .bold()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(videoItems) { item in
                                VStack {
                                    Image(systemName: "play.tv")
                                        .font(.system(size: 100))
                                    Text("\(item.title)")
                                        .bold()
                                    Button("Play") {
                                        outerVideoURLObject.currentVideoURL = item.videoURL
                                        outerVideoURLObject.currentVideoTitle = item.title
                                        print(item.videoURL)
                                    }
                                }
                                .id(item.id)
                            }
                            //                            ScrollViewReader { value in
                            //                                Button {
                            //                                    value.scrollTo(videoItems[0].id)
                            //                                } label: {
                            //                                Image(systemName:"arrowshape.turn.up.backward")
                            //                                }
                            //                            }
                        }
                        .padding()
                        
                        
                    }
                }
            }
            else {
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
