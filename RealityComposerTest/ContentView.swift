//
//  ContentView.swift
//  RealityComposerTest
//
//  Created by Daniel Dähling on 16.07.20.
//  Copyright © 2020 Daniel Dähling. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewControllerContainer().edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
