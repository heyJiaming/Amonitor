//
//  BandInformation.swift
//  Amonitor
//
//  Created by 乐野 on 2016/12/30.
//  Copyright © 2016年 leye. All rights reserved.
//

import UIKit

// 频带信息
class BandInformation: NSObject {
    // 是否开启了这个频带的滤波
    var isOn: Bool = false
    // 选择的滤波器（0~4）
    var filterSelected: Int = 0 {
        didSet {
            calculateResponse()
        }
    }
    // 五个滤波器
    var filters: [FilterInformation] = []
    // 计算出的幅频响应
    var response: [Float] = []
    
    var freq: Float = 20 {
        didSet {
            if freq < 20 {
                freq = 20
            } else if freq > 20000 {
                freq = 20000
            }
            calculateResponse()
        }
    }
    
    var gain: Float = 0 {
        didSet {
            if gain < -20 {
                gain = -20
            } else if gain > 20 {
                gain = 20
            }
            calculateResponse()
        }
    }
    
    var qValue: Float {
        set {
            filters[filterSelected].qValue = newValue
            calculateResponse()
        }
        get {
            return filters[filterSelected].qValue
        }
    }
    
    var qRange: (Float, Float) {
        get {
            switch filterSelected {
            // high pass, low pass
            case 0, 4: return (FilterInformation.lphp_q_min, FilterInformation.lphp_q_max)
            // shelf
            case 1, 3: return (FilterInformation.shelf_q_min, FilterInformation.shelf_q_max)
            // peak
            case 2: return(FilterInformation.peak_q_min, FilterInformation.peak_q_max)
            default: return (FilterInformation.lphp_q_min, FilterInformation.lphp_q_max)
            }
        }
    }
    
    var qUnit: Float {
        get {
            return (qRange.1 - qRange.0) / 80
        }
    }
    
    // 为便于调整旋钮图片，算出档位，作为图片下标
    var qLevel: Int {
        get {
            let value = Int((qValue - qRange.0) / qUnit)
            return value != 80 ? value : 79
        }
    }
    
    override init() {
        super.init()
        var filter1 = FilterInformation()
        filter1.filterType = .highPass
        filter1.qValue = FilterInformation.lphp_q_min
        filters.append(filter1)
        
        var filter2 = FilterInformation()
        filter2.filterType = .lowShelf
        filter2.qValue = FilterInformation.shelf_q_min
        filters.append(filter2)
        
        var filter3 = FilterInformation()
        filter3.filterType = .bell
        filter3.qValue = FilterInformation.peak_q_min
        filters.append(filter3)
        
        var filter4 = FilterInformation()
        filter4.filterType = .highShelf
        filter4.qValue = FilterInformation.shelf_q_min
        filters.append(filter4)
        
        var filter5 = FilterInformation()
        filter5.filterType = .lowPass
        filter5.qValue = FilterInformation.lphp_q_min
        filters.append(filter5)
        
        calculateResponse()
    }
    
    private func calculateResponse() {
        let (b, a) = returnBandA()
        (_, response) = try! EQ_Response.singleton.freqz(b: b, a: a)
    }
    
    private func returnBandA() -> ([Float], [Float]) {
        var b: [Float] = []
        var a: [Float] = []
        
        let w0: Float = 2 * Float(M_PI) * self.freq / LYEqualizerViewController.Fs
        let g_linear: Float = powf(10, self.gain / 40)
        let alpha = sin(w0)/(2 * self.qValue)
        
        switch self.filterSelected {
        // highpass
        case 0:
            b.append((1 + cos(w0))/2)
            b.append(-( 1 + cos(w0)))
            b.append((1 + cos(w0))/2)
            a.append(1 + alpha)
            a.append(-2*cos(w0))
            a.append(1 - alpha)
            
        // low shelf
        case 1:
            b.append(g_linear*((g_linear+1) - (g_linear-1)*cos(w0) + 2*sqrt(g_linear)*alpha))
            b.append(2*g_linear*((g_linear-1) - (g_linear+1)*cos(w0)))
            b.append(g_linear*((g_linear+1) - (g_linear-1)*cos(w0) - 2*sqrt(g_linear)*alpha))
            a.append((g_linear+1) + (g_linear-1)*cos(w0) + 2*sqrt(g_linear)*alpha)
            a.append(-2*((g_linear-1) + (g_linear+1)*cos(w0)))
            a.append((g_linear+1) + (g_linear-1)*cos(w0) - 2*sqrt(g_linear)*alpha)
            
        // bell (peaking)
        case 2:
            b.append(1 + alpha*g_linear)
            b.append(-2*cos(w0))
            b.append(1 - alpha*g_linear)
            a.append(1 + alpha/g_linear)
            a.append(-2*cos(w0))
            a.append(1 - alpha/g_linear)
            
        // high shelf
        case 3:
            b.append(g_linear*((g_linear+1) + (g_linear-1)*cos(w0) + 2*sqrt(g_linear)*alpha))
            b.append(-2*g_linear*((g_linear-1) + (g_linear+1)*cos(w0)))
            b.append(g_linear*((g_linear+1) + (g_linear-1)*cos(w0) - 2*sqrt(g_linear)*alpha))
            a.append((g_linear+1) - (g_linear-1)*cos(w0) + 2*sqrt(g_linear)*alpha)
            a.append(2*((g_linear-1) - (g_linear+1)*cos(w0)))
            a.append( (g_linear+1) - (g_linear-1)*cos(w0) - 2*sqrt(g_linear)*alpha)
            
        // lowpass
        case 4:
            b.append((1 - cos(w0))/2)
            b.append(1 - cos(w0))
            b.append((1 - cos(w0))/2)
            a.append(1 + alpha)
            a.append(-2*cos(w0))
            a.append(1 - alpha)
        default:
            break
        }
        
        return (b, a)
    }
    
    // 滤波器信息结构体
    struct FilterInformation {
        
        // 一些常数
        static let shelf_q_min: Float = 0.4
        static let shelf_q_max: Float = 1.0
        static let peak_q_min: Float = 0.5
        static let peak_q_max: Float = 5.0
        static let lphp_q_min: Float = 0.1
        static let lphp_q_max: Float = 1.5
        
        var filterType: FilterType = .highPass

        var qValue: Float = 0.5 {
            didSet {
                switch filterType {
                case .highPass, .lowPass:
                    if qValue < FilterInformation.lphp_q_min {qValue = FilterInformation.lphp_q_min}
                    else if qValue > FilterInformation.lphp_q_max {qValue = FilterInformation.lphp_q_max}
                    
                case .highShelf, .lowShelf:
                    if qValue < FilterInformation.shelf_q_min {qValue = FilterInformation.shelf_q_min}
                    else if qValue > FilterInformation.shelf_q_max {qValue = FilterInformation.shelf_q_max}
                    
                case .bell:
                    if qValue < FilterInformation.peak_q_min {qValue = FilterInformation.peak_q_min}
                    else if qValue > FilterInformation.peak_q_max {qValue = FilterInformation.peak_q_max}
                }
            }
        }
    }
    // 滤波器类型
    enum FilterType {
        case highPass, lowShelf, bell, highShelf, lowPass
    }
}
