//
//  PageView.swift
//  pruebaApp
//
//  Created by Juli Alexander Peña Tovar on 20/03/24.
//

import SwiftUI

struct PageView: View 
{
    var page: Page
    var body: some View 
    {
        VStack(spacing: 0)
        {
            Image("\(page.imageUrl)")
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .padding()
            Text(page.name)
                .font(.system(size: 16))
        }
    }
}

//This structure allows to visualize how this view looks like.
struct PageView_Previews: PreviewProvider
{
    static var previews: some View
    {
        PageView(page: Page.samplePage)
    }
}


