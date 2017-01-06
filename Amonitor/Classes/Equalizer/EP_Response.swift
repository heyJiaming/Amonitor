//
//  EP_Response.swift
//  Amonitor
//
//  Created by 乐野 on 2016/12/30.
//  Copyright © 2016年 leye. All rights reserved.
//

import UIKit
import Accelerate

// 计算频响曲线的类
class EQ_Response: NSObject {
    static var singleton: EQ_Response!
    
    private var pointNumber: Int!
    private var fft_len: Int!
    private var nOfSetup: Int!
    private var dftSetup: vDSP_DFT_Setup!
    private var zeroArray: [Float]!
    private var b_in: [Float]!
    private var a_in: [Float]!
    private var b_out_r: [Float] = []
    private var b_out_i: [Float] = []
    private var a_out_r: [Float] = []
    private var a_out_i: [Float] = []
    private var dftResult: [Float] = []
    private var tempFloat: Float = 0
    private var freqPoints: [Float] = []
    
    init(pointNumber: Int) {
        self.pointNumber = pointNumber
        self.fft_len = 2 * pointNumber
        self.nOfSetup = 2 * self.fft_len
        dftSetup = vDSP_DFT_zrop_CreateSetup(nil, UInt(nOfSetup), vDSP_DFT_Direction.FORWARD)
        
        zeroArray = [Float].init(repeating: 0, count: fft_len)
        dftResult = [Float].init(repeating: 0, count: pointNumber)
        let halfFs = LYEqualizerViewController.Fs / 2
        let freqStride = stride(from: Float(0), to: Float(halfFs), by: Float(halfFs)/Float(pointNumber))
        freqPoints = Array.init(freqStride)
        b_in = [Float].init(repeating: 0, count: fft_len)
        a_in = [Float].init(repeating: 0, count: fft_len)
        b_out_r = [Float].init(repeating: 0, count: fft_len)
        b_out_i = [Float].init(repeating: 0, count: fft_len)
        a_out_r = [Float].init(repeating: 0, count: fft_len)
        a_out_i = [Float].init(repeating: 0, count: fft_len)
    }
    
    /**
     返回：([频率(Hz)], [增益(db)])
     */
    func freqz(b: [Float], a: [Float]) throws -> ([Float], [Float]) {
        
        for i in 0 ..< fft_len {
            b_in[i] = 0
            a_in[i] = 0
            b_out_r[i] = 0
            b_out_i[i] = 0
            a_out_r[i] = 0
            a_out_i[i] = 0
        }
        
        if b.count != a.count {
            throw EP_Error.numbersOfTwoInputsNotEqual
        }
        
        var j = 0
        for i in 0 ..< b.count {
            j = i % fft_len
            a_in[j] += a[j]
            b_in[j] += b[j]
        }
        
        vDSP_DFT_Execute(dftSetup, a_in, zeroArray, &a_out_r, &a_out_i)
        vDSP_DFT_Execute(dftSetup, b_in, zeroArray, &b_out_r, &b_out_i)
        
        // unpack the result
        a_out_i[0] = 0
        b_out_i[0] = 0
        
        
        
        for i in 0 ..< pointNumber {
            tempFloat = sqrt((b_out_r[i] * b_out_r[i] + b_out_i[i] * b_out_i[i])/(a_out_r[i] * a_out_r[i] + a_out_i[i] * a_out_i[i]))
            
            dftResult[i] = 20 * log10((tempFloat * 1000).rounded(.down) / 1000.0)
        }
        
        return (freqPoints, dftResult)
    }
}
