//
//  ContentView.swift
//  AVPlayerView
//
//  Created by New User on 18/3/20.
//  Copyright © 2020 New User. All rights reserved.
//

import SwiftUI

struct PlayerControlView: View {
    @ObservedObject var presenter: MainViewPresenter
    var body: some View {
        HStack {
            Button(
                action: { self.presenter.onPlayButtonClicked() },
                label: { Text(self.$presenter.playButtonText.wrappedValue).padding() }
            )
            Slider(
                value: $presenter.sliderValue,
                onEditingChanged: { _ in self.presenter.onSliderValueUpdated() }
            )
        }
    }
}

struct PlayerRenderView: UIViewRepresentable {
    typealias UIViewType = UIView
    @ObservedObject var presenter: MainViewPresenter
    @Binding var updateView: Bool

    func makeUIView(context: UIViewRepresentableContext<PlayerRenderView>) -> UIView {
        let view = UIView()
        view.layer.addSublayer(presenter.avPlayerLayer!)
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerRenderView>) {
        if updateView {
            let height = presenter.videoSize!.height / presenter.videoSize!.width * uiView.frame.size.width
//            let newFrame = CGRect(
//                origin: uiView.bounds.origin,
//                size: CGSize(width: uiView.bounds.size.width, height: height)
//            )
            let newFrame = uiView.bounds
            presenter.setFrame(rect: newFrame)
        }
    }
}

struct ContentView: View {
    @ObservedObject var presenter = MainViewPresenter()
    var body: some View {
        VStack {
            PlayerRenderView(presenter: self.presenter, updateView: self.$presenter.updatePlayer)
            if $presenter.updatePlayer.wrappedValue {
                PlayerControlView(presenter: self.presenter)
                    .padding()
            }

            Text("This is a sample video Player implemented using SwiftUI").padding()
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
