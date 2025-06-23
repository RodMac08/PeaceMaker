//
//  SplashScreen.swift
//  PeaceMaker
//
//  Created by Rodrigo Macias Ruiz on 22/06/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("appOpener")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .infinity, height: .infinity)
            }
        }
    }
}
