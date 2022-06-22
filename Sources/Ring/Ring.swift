import SwiftUI

public enum CenterType {
    case percentage
    case remaining
    case percentageRemaining
    case nothing
}

@available(macOS 10.15, *)
@available(iOS 15, *)
public struct RingProgressView: View {
    
    public init(totalValue: Int, mainColor: Binding<Color>, secondaryColor: Binding<Color>, centerType: CenterType, isButtonActive: Bool = false,completion: @escaping (Bool) -> () ) {
        self.totalValue = totalValue
        self._progressFrontColor = mainColor
        self._progressBackColor = secondaryColor
        self.centerType = centerType
        self.isButtonActive = isButtonActive
        self.completion = completion
    }
    var totalValue: Int
    @Binding var progressFrontColor: Color
    @Binding var progressBackColor: Color
    var isButtonActive: Bool
    var centerType: CenterType
    var completion: (Bool) -> ()
    public var body: some View {
        if #available(macOS 12, *) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                CircularView(totalValue: totalValue,
                             progressFrontColor: $progressFrontColor,
                             progressBackColor: $progressBackColor,centerType: centerType,
                             changer: context.date,isButtonActives: isButtonActive) { completed in
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
public struct CircularView: View {
    @State var value = 0
    @State var paused: Bool = false
    var totalValue: Int
    @Binding var progressFrontColor: Color
    @Binding var progressBackColor: Color
    var centerType: CenterType
    var changer: Date
    var isButtonActives: Bool
    var completion: (Bool) -> ()
    
    public var body: some View {
        if #available(macOS 11.0, *) {
            VStack {
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
                        if !paused {
                            value += 1
                        }
                        
                    }
                }
                
                if isButtonActives {
                    HStack {
                        
                        Button {
                            paused.toggle()
                        }
                        
                        label: {
                            ZStack{
                                progressFrontColor
                                    Image(systemName: paused ? "play.circle": "pause.circle")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40, alignment: .center)
                            }
                            .cornerRadius(40)
                            .frame(width:80,height: 80)
                        }
                    }
                    
                    Spacer()
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
}


