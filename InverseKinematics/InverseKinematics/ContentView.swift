//
//  ContentView.swift
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/17.
//

import SwiftUI

struct ContentView: View {
    var renderer = Renderer()
    var body: some View {
        InverseKinematicsView(renderer: renderer)
            .onTapGesture { renderer.simulate() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
