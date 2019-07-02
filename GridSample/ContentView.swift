//
//  ContentView.swift
//  GridSample
//
//  Created by Kazuhiro Hayashi on 7/1/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import Photos

struct ContentView : View {
    @ObjectBinding var photoLibrary = PhotoLibrary()

    var body: some View {
        NavigationView {
            
            SimpleGridView(data: self.photoLibrary.photoAssets.identified(by: \.self)) { a in
                PhotoRow(photo: a).frame(width: 110, height: 110)
                }.edgesIgnoringSafeArea(.all)
                .onAppear {
                    self.photoLibrary.requestAuthorization()
                }
        }
        .navigationBarTitle(Text("Photos"))
  
    }
}

struct PhotoRow: View {
    @ObjectBinding var photo: Asset
    @State var isDisappeard = false
    var body: some View {
        HStack {
            if photo.image != nil {
                withAnimation {
                    Image(uiImage: photo.image!)
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .clipped()
                }
            } else {
                Color.white.frame(width: 100, height: 100)
            }
            }.onAppear {
                self.isDisappeard = false
                self.photo.request()
            }.onDisappear {
                self.isDisappeard = true
        }
    }
}
#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif


struct SimpleGridView<Data, Content>: UIViewRepresentable where Data: RandomAccessCollection, Content: View, Data.Element: Identifiable, Data.Index == Int {
    
    var data: Data
    var space: Float = 8
    var content: (Data.Element.IdentifiedValue) -> Content
    
    func makeCoordinator() -> SimpleGridView.Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SimpleGridView>) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(space)
        layout.minimumInteritemSpacing = CGFloat(space)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GridCell<Content>.self, forCellWithReuseIdentifier: "identifier")
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<SimpleGridView>) {
        context.coordinator.parent = self
        uiView.reloadData()
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: SimpleGridView
        
        init(_ view: SimpleGridView) {
            parent = view
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.data.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let element = parent.data[indexPath.row]
            let content = parent.content(element.identifiedValue)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath) as! GridCell<Content>
            cell.configure(content: content)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let element = parent.data[indexPath.row]
            let controller = UIHostingController(rootView: parent.content(element.identifiedValue))
            return controller.sizeThatFits(in: UIView.layoutFittingCompressedSize)
        }
    }
}

class GridCell<Content>: UICollectionViewCell where Content: View  {
    var content: UIHostingController<Content>?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        content?.view.frame = bounds
        
    }
    
    func configure(content: Content) {
        if let _content = self.content {
            _content.rootView = content
        } else {
            let controller = UIHostingController(rootView: content)
            addSubview(controller.view)
            self.content = controller
        }
    }
}
