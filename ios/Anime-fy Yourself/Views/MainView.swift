//
//  MainView.swift
//  Anime-fy Yourself
//
//  Created by Yonatan Mittlefehldt on 2021-12-07.
//

import SwiftUI

struct MainView: View {
    @StateObject private var model = MainViewModel()

    var body: some View {
        ZStack {
            HStack {
                if model.displayMode.shouldShowOriginal {
                    FrameView(image: model.frame)
                        .edgesIgnoringSafeArea(.all)
                }

                if model.displayMode.shouldShowAnime {
                    FrameView(image: model.animeFrame)
                        .edgesIgnoringSafeArea(.all)
                }
            }

            ErrorView(error: model.error)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.model.nextFrameDisplayMode()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
