//
//  SlideintoScreenView.swift
//  pruebaApp
//
//  Created by user on 20/03/24.
//

import SwiftUI

struct SlideintoScreenView: View 
{
    
    @State private var pageIndex = 0
    private let pages: [Page] =   Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View 
    {
        TabView(selection: $pageIndex)
        {
            ForEach(pages)
            {
                page in
                VStack
                {
                    Spacer()
                    PageView(page: page)
                    Spacer()
                    if page == pages.last
                    {
                        Button("Next",action: goToMenu) .buttonStyle(.bordered)
                    }
                    else
                    {
                        Button("Next", action: incrementPage)
                    }
                    Spacer()
                    
                }
                .tag(page.tag)
            }
            
        }
        .animation(.easeIn, value: pageIndex)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .onAppear
        {
            dotAppearance.currentPageIndicatorTintColor = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
        
    }
    
    func incrementPage()
    {
        pageIndex += 1
    }
    
    func goToMenu()
    {
        NavigationLink(destination: MenuView())
        {
            
        }
    }
    
    }
#Preview 
{
    SlideintoScreenView()
}
