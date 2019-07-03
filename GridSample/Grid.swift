//
//  Grid.swift
//  GridSample
//
//  Created by kahayash on 7/3/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI


struct Grid<Data, Content>: UIViewRepresentable where
    Data: RandomAccessCollection,
    Content: View, Data.Element:
    Identifiable, Data.Index == Int {
    
    var data: Data
    var space: Float = 5
    var content: (Data.Element.IdentifiedValue) -> Content
    
    func makeCoordinator() -> Grid.Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<Grid>) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(space)
        layout.minimumInteritemSpacing = CGFloat(space)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GridCell<Content>.self, forCellWithReuseIdentifier: "identifier")
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<Grid>) {
        context.coordinator.parent = self
        uiView.reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: Grid
        
        init(_ view: Grid) {
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
    
    override func prepareForReuse() {
        content?.view.removeFromSuperview()
        content = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        content?.view.frame = bounds
    }
    
    func configure(content: Content) {
        let controller = UIHostingController(rootView: content)
        addSubview(controller.view)
        self.content = controller
    }
}
