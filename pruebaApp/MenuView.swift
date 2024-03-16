//
//  ContentView.swift
//  test
//
//  Created by Juan Sebastian Ibañez Capacho on 7/03/24.
//

import SwiftUI

struct MenuView: View {
    @State var toggleIsOn: Bool = true
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .fill(Color("LightWhite"))
                    .frame(width:290,height:40)
                Text("Universidad de Los Andes Homepage")
                    .font(.caption)
            }
            Spacer()
                .frame(width:330,height:50)
            ZStack{
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .frame(width:330,height:140)
                    .offset(x: 0 ,y:40.0)
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .fill(Color("DarkGray"))
                    .frame(width:330,height:140)
                    .offset(x: 0 ,y:30.0)
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .fill(Color(.gray))
                    .frame(width:330,height:140)
                    .offset(x: 0 ,y:20.0)
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .fill(Color("LightWhite"))
                    .frame(width:330,height:140)
                    .offset(x: 0 ,y:10.0)
                Image("Campus")
                    .resizable()
                    .frame(width:330,height:160)
                    .cornerRadius(30)
                    .offset(x: 0 ,y:-20.0)
                Rectangle()
                    .fill(Color("LightWhite"))
                    .frame(width:314,height:30)
                    .offset(x: 0 ,y:55.0)
                Rectangle()
                    .fill(Color("LightWhite"))
                    .frame(width:326,height:20)
                    .offset(x: 0 ,y:50.0)
                Rectangle()
                    .fill(Color("LightWhite"))
                    .frame(width:330,height:6)
                    .offset(x: 0 ,y:37.0)
                Text("Discover the latest news about security at")
                    .font(.footnote)
                    .offset(x: 0 ,y:47.0)
                Text("Universidad de los andes")
                    .font(.footnote)
                    .offset(x: 0 ,y:65.0)
                
            }
            Spacer()
                .frame(width:330,height:40)
            Button{
            }
                label:{
                    Text("Contatc Student Brigrade")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 210, height: 45)
                        .background{
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color("LighterGreen"))
                        }
                }
                .padding(.top)
                .buttonStyle(ScaleButtonStyle())
            
            Button{
            }
                label:{
                    Text("Report MAAD Case")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 210, height: 45)
                        .background{
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color("LighterGreen"))
                        }
                }
                .padding(.top)
                .buttonStyle(ScaleButtonStyle())
           
            Button{
            }
                label:{
                    Text("Safety Tips on the Campus")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 210, height: 45)
                        .background{
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color("LighterGreen"))
                        }
                }
                .padding(.top)
                .buttonStyle(ScaleButtonStyle())
           
            Spacer()
                .frame(height: 30)
            VStack{
                Toggle(
                    isOn: $toggleIsOn,
                    label: {
                        Text("Activate alerts")
                            .font(.footnote)
                    }
                )
                .toggleStyle(SwitchToggleStyle(tint: Color("LighterGreen")))
            }
            .padding(.horizontal,108)
                
            
            
            
            Spacer()
        }
        .padding()
        
    }
    
}

