//
//  SlideintoScreenView.swift
//  pruebaApp
//
//  Created by user on 20/03/24.
//

import SwiftUI

struct SlideintoScreenView: View 
{
    @State private var isPresentingMenuView = false
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
                        Button("Go to Menu") {
                            isPresentingMenuView.toggle()
                               }
                               .fullScreenCover(isPresented: $isPresentingMenuView) {
                                   RootView()
                               }
                               .padding()
                               .foregroundColor(.white)
                               .background(Color("LightGreen"))
                               .cornerRadius(10)
                               .frame(width: 150, height: 50)
                    }
                    else
                    {
                        Button("Next", action: incrementPage)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(.gray))
                            .cornerRadius(10)
                            .frame(width: 150, height: 50)
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
    
    func gotoFirst()
    {
        pageIndex = 0
    }
    
}
struct SlideintoScreeView_Previews: PreviewProvider {
    static var previews: some View {
        SlideintoScreenView()
    }
}
