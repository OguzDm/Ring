//
//  CircularProgressView.swift
//  CircularTimer
//
//  Created by Oğuz Demirhan on 21.06.2022.
//

import SwiftUI

enum CenterType {
    case percentage
    case remaining
    case percentageRemaining
    case nothing
}

@available(macOS 10.15, *)
@available(iOS 15, *)
struct CircularProgressView: View {
    var totalValue: Int
    @Binding var progressFrontColor: Color
    @Binding var progressBackColor: Color
    var centerType: CenterType
    var completion: (Bool) -> ()
    var body: some View {
        if #available(macOS 12, *) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                CircularView(totalValue: totalValue,
                             progressFrontColor: $progressFrontColor,
                             progressBackColor: $progressBackColor,centerType: centerType,
                             changer: context.date) { completed in
                    completion(completed)
                }
            }
            .padding(.horizontal)
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(macOS 10.15, *)
struct CircularView: View {
    @State var value = 0
    var totalValue: Int
    @Binding var progressFrontColor: Color
    @Binding var progressBackColor: Color
    var centerType: CenterType
    var changer: Date
    var completion: (Bool) -> ()
    
    var body: some View {
        if #available(macOS 11.0, *) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 30)
                    .fill(progressBackColor)
                
                Circle()
                    .trim(from: 0, to: CGFloat(value ) / CGFloat(totalValue))
                    .stroke(style: StrokeStyle(lineWidth: 30,lineCap: .round))
                    .rotation(.degrees(-90))
                    .fill(progressFrontColor)
                
                centerTextView()
                
            }
            .onChange(of: changer) { _ in
                if value == totalValue {
                    completion(true)
                }
                else {
                    //withAnimation {
                    value += 1
                    
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder func centerTextView () -> some View {
        switch centerType {
        case .percentage:
            Text("\(calculatePercentage()) %")
                .font(.title)
                .foregroundColor(progressFrontColor)
        case .remaining:
            Text("\(calculateRemaining()) Remain")
                .font(.title)
                .foregroundColor(progressFrontColor)
        case .percentageRemaining:
            VStack {
                Text("\(calculatePercentage()) %")
                    .font(.title)
                    .foregroundColor(progressFrontColor)
                
                Text("\(calculateRemaining()) Remain")
                    .font(.title)
                    .foregroundColor(progressBackColor)
            }
        case .nothing:
            
            EmptyView()
        }
    }
    
    private func calculatePercentage() -> Int {
        return value * 100 / totalValue
    }
    
    private func calculateRemaining() -> Int {
        
        return totalValue - value
        
    }
    
    
    struct CircularProgressView_Previews: PreviewProvider {
        static var previews: some View {
            
            CircularProgressView(totalValue: 120,progressFrontColor: .constant(.red),progressBackColor: .constant(.gray.opacity(0.5)), centerType: .percentage) { completed in
            }
        }
    }
}

