//
//  ContentView.swift
//  pruebaApp
//
//  Created by IMAC on 3/03/24.
//

import SwiftUI

struct ContentView: View
{
    @State private var isShowingDetailView = false
    @State var isClicked : Bool = false
    let image = Image("resQLogo")
    var body: some View
    {
        NavigationView {
        ZStack
            {
                
                Color("LightGreen")
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .foregroundStyle(.linearGradient(colors: [Color("LighterGreen"), Color("LightGreen")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .ignoresSafeArea()
                
                VStack(spacing: 20){
                    
                    Image("El")
                        .offset(y:-80)
                    Text("resQ")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("Security at your fingertips")
                        .foregroundColor(.white)
                    
                    
                }
                
                NavigationLink(destination: SlideintoScreenView(), isActive: $isShowingDetailView) { EmptyView() }
                    .hidden()
                
                Button(action: {
                    isShowingDetailView = true
                
                }) {
                    Text("Get Started")
                        .foregroundColor(Color("LighterGreen"))
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white)
                        )
                        .padding(.top)
                }
                .offset(y: 120)

                    
                    
                    
                }
            }
            
        .navigationBarHidden(true)
        }
        
    }

    
struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
            ContentView()
    }
}


