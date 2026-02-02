//
//  VantagWidgetBundle.swift
//  VantagWidget
//
//  Widget Bundle for Vantag
//

import WidgetKit
import SwiftUI

@main
struct VantagWidgetBundle: WidgetBundle {
    var body: some Widget {
        VantagSmallWidget()
        VantagMediumWidget()
        VantagWidgetLiveActivity()
    }
}
