//
//  PageModel.swift
//  pruebaApp
//
//  Created by Julio Alexander Peña Tovar  on 20/03/24.
//

import Foundation

struct Page: Identifiable, Equatable
{
    let id = UUID()
    var name: String
    var imageUrl: String
    var tag: Int
    
    static var samplePage = Page(name: "Ejemplo1", imageUrl: "PlaceHolder", tag: 0)
    
    // These are the different pages that are displayed after the get started button.
    static var samplePages:[Page] =
    [
        Page(name:"Ejemplo1",  imageUrl: "PlaceHolder", tag: 0),
        Page(name:"Ejemplo2",  imageUrl: "PlaceHolder", tag: 1),
        Page(name:"Ejemplo3",  imageUrl: "PlaceHolder", tag: 2)
    ]
    
    
}
