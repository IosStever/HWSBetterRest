//
//  ContentView.swift
//  HWSBetterRest
//
//  Created by Steven Robertson on 10/18/19.
//  Copyright © 2019 Steven Robertson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    let model = SleepCalculator()
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var bedtime: String  {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
              let hour = (components.hour ?? 0) * 60 * 60
              let minute = (components.minute ?? 0) * 60
              do {
                  let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                  
                  let sleepTime = wakeUp - prediction.actualSleep
                  let formatter = DateFormatter()
                  formatter.timeStyle = .short

                  return formatter.string(from: sleepTime)
              } catch {
                  return "Sorry, there was a problem calculating your bedtime."
              }
    }
    
    var cupsText: String {
        if coffeeAmount == 1 {
            return "1 cup"
        } else {
            return "\(coffeeAmount) cups"
        }
    }
    
    var addTimeForCoffee: String  {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
              let hour = (components.hour ?? 0) * 60 * 60
              let minute = (components.minute ?? 0) * 60
              do {
                  let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                  
                  let sleepTime = prediction.actualSleep - (sleepAmount*3600)
                  let hours = Int(sleepTime) / 3600
                  let minutes = Int(sleepTime) / 60 % 60
               if hours == 0 {
                return "\(minutes) minutes"
                }
                else if hours == 1 {
                   return "\(hours) hour and \(minutes) minutes"
                }
                else {
                  return "\(hours) hours and \(minutes) minutes" //String(format:"%02i:%02i", hours, minutes)
                }
              } catch {
                  return "Sorry, there was a problem calculating your bedtime."
              }
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Text("Your ideal bedtime is \(bedtime)")
                }.font(.title)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                Text("If you want \(sleepAmount, specifier: "%.2f") hours of sleep and you drink \(cupsText) of coffee, you will need to go to bed \(addTimeForCoffee) earlier.")
                    .font(.caption)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

                VStack(spacing: 0) {
                 Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    //.datePickerStyle(WheelDatePickerStyle())
                    
                }  .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

                VStack(spacing: 10) {
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }.fixedSize()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                VStack(spacing: 10) {
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(value: $coffeeAmount, in: 1...20) {
                    if coffeeAmount == 1 {
                        Text("1 cup")
                    } else {
                        Text("\(coffeeAmount) cups")
                    }
                
                    }.fixedSize()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
        .navigationBarTitle("BetterRest")
//        .navigationBarItems(trailing:
//            Button(action: calculateBedtime) {
//                Text("Calculate")
//        }        )
//        .alert(isPresented: $showingAlert) {
//            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    func calculateBedtime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is…"
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environment(\EnvironmentValues.colorScheme, ColorScheme.dark)
    }
}
