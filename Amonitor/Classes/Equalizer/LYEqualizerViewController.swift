//
//  LYEqualizerViewController.swift
//  Amonitor
//
//  Created by 乐野 on 2016/12/22.
//  Copyright © 2016年 leye. All rights reserved.
//

/*
 SWIFT_CLASS_NAMED("LYEqualizerViewController")
 @interface LYEqualizerViewController : UIViewController
 - (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
 @end
 */

import UIKit
import Accelerate

@objc(LYEqualizerViewController)

class LYEqualizerViewController: UIViewController {
    
    // MARK: - 一些常数
    private let mainColor = UIColor(red: 254.0 / 255, green: 180.0 / 255, blue: 183.0 / 255, alpha: 1)
    private let offColor = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 239.0 / 255, alpha: 1)
    private let pointNumber = 2048
    static let Fs: Float = 44100
    
    // MARK: - 总开关
    private var masterSwitch: UIButton!
    private var eqIsOn: Bool = false
    private var previousBandsOn: [Int] = []
    
    // MARK: - 频带信息
    private var bands: [BandInformation] = []
    
    // MARK: - 选中的频带（0~4）
    private var bandSelected: Int = 0
    
    // MARK: - 各个按钮及修饰
    private var filterButtons: [UIButton] = []
    private var oldFilter: Int = 0
    private var bandSelectingButtons: [UIButton] = []
    private var bandLineView: UIImageView!
    private var bandLineImages: [UIImage] = []
    private var bandPowerBuutons: [UIButton] = []
    
    // MARK: - Q值旋钮
    private var qRotatorImage: [UIImage] = []
    private var qRotatorOffImage: [UIImage] = []
    private var rotatorImageView: UIImageView!
    private var qValueLabel: UILabel!
    private var qLabel: UILabel!
    private var initialQ: Float!
    
    // MARK: - 画频响曲线的view
    private var responseView: ResponseView!
    private var freqPoints: [Float] = []
    
    // MARK: - 计算频响曲线的类
    private var eq_response: EQ_Response!
    
    // MARK: - 频率滑动条
    private var freqTitleLabel: UILabel!
    private var freqValueLabel: UILabel!
    private var freqSliderBackground: UIImageView!
    private var freqSliderHandler: UIImageView!
    private var freqSliderBar: UIImageView!
    private var freqMaskLayer: CALayer!
    private var freqHandlerMovingDistance: CGFloat = 0
    private var initialFreqHandlerXMin: CGFloat!
    private var initialFreqMaskXMin: CGFloat!
    private var freqK: Float!
    
    // MARK: - 增益滑动条
    private var gainTitleLabel: UILabel!
    private var gainValueLabel: UILabel!
    private var gainSliderBackground: UIImageView!
    private var gainSliderHandler: UIImageView!
    private var gainSliderBar: UIImageView!
    private var gainMaskLayer: CALayer!
    private var gainHandlerMovingDistance: CGFloat = 0
    private var initialGainHandlerXMin: CGFloat!
    private var initialGainMaskXMin: CGFloat!
    private var gainK: Float!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEQ_response()
        
        setResponseView()
        
        setDefaultBands()
        
        setBackground()
        
        setFilterButtons()
        
        setQRotator()
        
        setBandButtons()
        
        setFreqSlider()
        
        setGainSlider()
        
        setMasterSwitch()
    }
    
    override func awakeFromNib() {
    }
    
    // MARK: - 频带数据初始化
    
    private func setDefaultBands() {
        for _ in 0 ..< 5 {
            let band = BandInformation()
            bands.append(band)
        }
    }
    
    // MARK: - 初始设置
    
    private func setBackground() {
        // 配置背景颜色
        view.backgroundColor = UIColor.black
        
        // 配置、添加坐标图片
        let coordinateImage = UIImage(named: "eq_eq图表")
        let coordinateView = UIImageView(image: coordinateImage)
        coordinateView.sizeToFit()
        coordinateView.frame = CGRect(origin: CGPoint(x: 19, y: 25), size: coordinateView.frame.size)
        view.addSubview(coordinateView)
    }
    
    private func setFilterButtons() {
        // 创建五个滤波器的按钮
        for index in 0 ..< 5 {
            let button = UIButton()
            if index == bands[bandSelected].filterSelected && bands[bandSelected].isOn {
                let onImage = UIImage(named: "eq_图形\(index + 1)_band\(bandSelected + 1)")
                button.setImage(onImage, for: .normal)
            } else {
                let offImage = UIImage(named: "eq_图形\(index + 1)_off")
                button.setImage(offImage, for: .normal)
            }
            oldFilter = bands[bandSelected].filterSelected
            button.sizeToFit()
            button.addTarget(self, action: #selector(selectFilter(sender:)), for: UIControlEvents.touchUpInside)
            view.addSubview(button)
            filterButtons.append(button)
        }
        
        // 摆放五个按钮
        filterButtons[0].frame = CGRect(origin: CGPoint(x: 38 / 2, y: 716 / 2), size: filterButtons[0].frame.size)
        filterButtons[1].frame = CGRect(origin: CGPoint(x: 170 / 2, y: 708 / 2), size: filterButtons[1].frame.size)
        filterButtons[2].frame = CGRect(origin: CGPoint(x: 308 / 2, y: 704 / 2), size: filterButtons[2].frame.size)
        filterButtons[3].frame = CGRect(origin: CGPoint(x: 432 / 2, y: 708 / 2), size: filterButtons[3].frame.size)
        filterButtons[4].frame = CGRect(origin: CGPoint(x: 572 / 2, y: 716 / 2), size: filterButtons[4].frame.size)
    }
    
    private func setBandButtons() {
        // 创建频带选择按钮及线框
        for index in 0 ..< 5 {
            
            // 选择按钮
            let button = UIButton()
            if bands[index].isOn {
                let image = UIImage(named: "eq_Band\(index + 1)")
                button.setImage(image, for: .normal)
            } else {
                let image = UIImage(named: "eq_Band\(index + 1)_off")
                button.setImage(image, for: .normal)
            }
            button.sizeToFit()
            button.addTarget(self, action: #selector(selectBand(sender:)), for: UIControlEvents.touchUpInside)
            view.addSubview(button)
            bandSelectingButtons.append(button)
            
            // 线框
            let lineImage = UIImage(named: "eq_线框\(index + 1)")!
            bandLineImages.append(lineImage)
            
            // 启动按钮
            let powerButton = UIButton()
            if bands[index].isOn {
                let powerButtonImage = UIImage(named: "eq_band\(index + 1)图标")
                powerButton.setImage(powerButtonImage, for: .normal)
            } else {
                let powerButtonImage = UIImage(named: "eq_band图标_off")
                powerButton.setImage(powerButtonImage, for: .normal)
            }
            powerButton.sizeToFit()
            powerButton.contentMode = .center
            powerButton.addTarget(self, action: #selector(toggleBand), for: .touchUpInside)
            view.addSubview(powerButton)
            bandPowerBuutons.append(powerButton)
        }
        
        // 摆放频带选择按钮
        bandSelectingButtons[0].frame = CGRect(origin: CGPoint(x: 188 / 2, y: 556 / 2), size: bandSelectingButtons[0].frame.size)
        bandSelectingButtons[1].frame = CGRect(origin: CGPoint(x: 494 / 2, y: 556 / 2), size: bandSelectingButtons[1].frame.size)
        bandSelectingButtons[2].frame = CGRect(origin: CGPoint(x: 802 / 2, y: 556 / 2), size: bandSelectingButtons[2].frame.size)
        bandSelectingButtons[3].frame = CGRect(origin: CGPoint(x: 1106 / 2, y: 556 / 2), size: bandSelectingButtons[3].frame.size)
        bandSelectingButtons[4].frame = CGRect(origin: CGPoint(x: 1414 / 2, y: 556 / 2), size: bandSelectingButtons[4].frame.size)
        
        // 摆放频带启动按钮
        
        let largerSize = CGSize(width: bandPowerBuutons[0].frame.size.width + 20 , height: bandPowerBuutons[0].frame.size.height + 10)
        bandPowerBuutons[0].frame = CGRect(origin: CGPoint(x: 124 / 2 - 10, y: 564 / 2 - 10), size: largerSize)
        bandPowerBuutons[1].frame = CGRect(origin: CGPoint(x: 430 / 2 - 10, y: 564 / 2 - 10), size: largerSize)
        bandPowerBuutons[2].frame = CGRect(origin: CGPoint(x: 736 / 2 - 10, y: 564 / 2 - 10), size: largerSize)
        bandPowerBuutons[3].frame = CGRect(origin: CGPoint(x: 1042 / 2 - 10, y: 564 / 2 - 10), size: largerSize)
        bandPowerBuutons[4].frame = CGRect(origin: CGPoint(x: 1348 / 2 - 10, y: 564 / 2 - 10), size: largerSize)
        
        
        // 添加频带线框
        bandLineView = UIImageView(image: bandLineImages[bandSelected])
        bandLineView.sizeToFit()
        bandLineView.frame = CGRect(origin: CGPoint(x: 38 / 2, y: 530 / 2), size: bandLineView.frame.size)
        view.addSubview(bandLineView)
    }
    
    func setQRotator(){
        // 将 80 张图读入内存
        for i in 1 ... 80 {
            qRotatorImage.append(UIImage(named: "eq_\(i)")!)
            qRotatorOffImage.append(UIImage(named: "eq_\(i - 1)_off")!)
        }

        rotatorImageView = UIImageView(image: qRotatorImage[bands[bandSelected].qLevel])
        rotatorImageView.sizeToFit()
        rotatorImageView.frame = CGRect(origin: CGPoint(x: 1402 / 2, y: 670 / 2), size: rotatorImageView.frame.size)
        
        // 添加拖动手势
        let gr = UIPanGestureRecognizer(target: self, action: #selector(dragQRotator))
        rotatorImageView.isUserInteractionEnabled = true
        rotatorImageView.addGestureRecognizer(gr)
        
        view.addSubview(rotatorImageView)
        
        // 设置上方的 q 值标签
        qValueLabel = UILabel()
        qValueLabel.frame = CGRect(x: 1402 / 2, y: 670 / 2 - 16, width: 84, height: 14)
        qValueLabel.textAlignment = .center
        qValueLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        qValueLabel.textColor = mainColor
        qValueLabel.text = String.init(format: "%.2f", bands[bandSelected].qValue)
        
        view.addSubview(qValueLabel)
        
        // 下方加一个 q 字母
        qLabel = UILabel()
        qLabel.frame = CGRect(x: 1402 / 2, y: 670 / 2 + 76, width: 84, height: 14)
        qLabel.textAlignment = .center
        qLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        qLabel.textColor = mainColor
        qLabel.text = "Q"
        
        view.addSubview(qLabel)
        
        updateRotator()
        
    }
    
    private func setResponseView() {
        responseView = ResponseView(frame: CGRect(x: 38 / 2, y: 74 / 2 , width: 1536 / 2, height: 458 / 2), pointNumber: self.pointNumber)
        let halfFs = LYEqualizerViewController.Fs / 2
        let freqStride = stride(from: Float(0), to: Float(halfFs), by: Float(halfFs)/Float(pointNumber))
        freqPoints = Array.init(freqStride)
        view.addSubview(responseView)
    }
    
    private func setEQ_response() {
        EQ_Response.singleton = EQ_Response(pointNumber: self.pointNumber)
    }
    
    private func setFreqSlider() {
        let backgroundImage = UIImage(named: "eq_拖动条")
        freqSliderBackground = UIImageView(image: backgroundImage)
        freqSliderBackground.sizeToFit()
        let barOrigin = CGPoint(x: 744 / 2, y: 704 / 2)
        let barSize = freqSliderBackground.frame.size
        let barRect = CGRect(origin: barOrigin, size: barSize)
        freqSliderBackground.frame = barRect
        
        view.addSubview(freqSliderBackground)
        
        let barImage = UIImage(named: "eq_拖动进度1")
        freqSliderBar = UIImageView(image: barImage)
        freqSliderBar.sizeToFit()
        freqSliderBar.frame = CGRect(origin: barOrigin, size: freqSliderBar.frame.size)
        view.addSubview(freqSliderBar)
        
        freqMaskLayer = CALayer()
        freqMaskLayer.contents = barImage?.cgImage
        freqMaskLayer.frame = CGRect(origin: CGPoint.zero, size: barSize)
        freqSliderBar.layer.mask = freqMaskLayer
        
        let handlerImage = UIImage(named: "eq_拖动1")
        freqSliderHandler = UIImageView(image: handlerImage)
        freqSliderHandler.sizeToFit()
        freqSliderHandler.frame = CGRect(origin: CGPoint(x: 1176 / 2, y: 684 / 2), size: freqSliderHandler.frame.size)
        initialFreqHandlerXMin = freqSliderHandler.frame.minX
        freqSliderHandler.isUserInteractionEnabled = true
        view.addSubview(freqSliderHandler)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(dragFreqHandler))
        freqSliderHandler.addGestureRecognizer(gr)
        
        freqTitleLabel = UILabel(frame: CGRect(x: 1238 / 2, y: 670 / 2 , width: 40, height: 14))
        freqTitleLabel.text = "Freq"
        freqTitleLabel.textAlignment = .left
        freqTitleLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        freqTitleLabel.textColor = UIColor.white
        view.addSubview(freqTitleLabel)
        
        freqValueLabel = UILabel(frame: CGRect(x: 1238 / 2, y: 698 / 2 , width: 60, height: 14))
        freqValueLabel.text = "22.0Hz"
        freqValueLabel.textAlignment = .left
        freqValueLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        freqValueLabel.textColor = UIColor.white
        view.addSubview(freqValueLabel)
        
        freqK = ((1176 - 730) / 2) / log(1000)
        
        updateFreqSlider()
    }
    
    private func setGainSlider() {
        let backgroundImage = UIImage(named: "eq_拖动条")
        gainSliderBackground = UIImageView(image: backgroundImage)
        gainSliderBackground.sizeToFit()
        let barOrigin = CGPoint(x: 744 / 2, y: 814 / 2)
        let barSize = gainSliderBackground.frame.size
        let barRect = CGRect(origin: barOrigin, size: barSize)
        gainSliderBackground.frame = barRect
        
        view.addSubview(gainSliderBackground)
        
        let barImage = UIImage(named: "eq_拖动进度1")
        gainSliderBar = UIImageView(image: barImage)
        gainSliderBar.sizeToFit()
        gainSliderBar.frame = CGRect(origin: barOrigin, size: gainSliderBar.frame.size)
        view.addSubview(gainSliderBar)
        
        gainMaskLayer = CALayer()
        gainMaskLayer.contents = barImage?.cgImage
        gainMaskLayer.frame = CGRect(origin: CGPoint.zero, size: barSize)
        gainSliderBar.layer.mask = gainMaskLayer
        
        let handlerImage = UIImage(named: "eq_拖动1")
        gainSliderHandler = UIImageView(image: handlerImage)
        gainSliderHandler.sizeToFit()
        gainSliderHandler.frame = CGRect(origin: CGPoint(x: 1176 / 2, y: 794 / 2), size: gainSliderHandler.frame.size)
        initialGainHandlerXMin = gainSliderHandler.frame.minX
        gainSliderHandler.isUserInteractionEnabled = true
        view.addSubview(gainSliderHandler)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(dragGainHandler))
        gainSliderHandler.addGestureRecognizer(gr)
        
        gainTitleLabel = UILabel(frame: CGRect(x: 1238 / 2, y: 780 / 2 , width: 40, height: 14))
        gainTitleLabel.text = "Gain"
        gainTitleLabel.textAlignment = .left
        gainTitleLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        gainTitleLabel.textColor = UIColor.white
        view.addSubview(gainTitleLabel)
        
        gainValueLabel = UILabel(frame: CGRect(x: 1238 / 2, y: 808 / 2 , width: 60, height: 14))
        gainValueLabel.text = "22.0Hz"
        gainValueLabel.textAlignment = .left
        gainValueLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        gainValueLabel.textColor = UIColor.white
        view.addSubview(gainValueLabel)
        
        gainK = ((1176 - 730) / Float(2)) / 40
        
        updateGainSlider()
    }
    
    private func setMasterSwitch(){
        let image = UIImage(named: "eq_OFF")
        masterSwitch = UIButton()
        masterSwitch.setImage(image, for: .normal)
        masterSwitch.sizeToFit()
        masterSwitch.addTarget(self, action: #selector(toggleMasterSwitch), for: .touchUpInside)
        masterSwitch.frame = CGRect(origin: CGPoint(x: 1704 / 2, y: 750 / 2), size: masterSwitch.frame.size)
        view.addSubview(masterSwitch)
        turnOffMasterSwitch()
    }
    
    // MARK: - 动作
    
    // 选中某个滤波器后所做的调整
    func selectFilter(sender: UIButton) {
        // 调整按钮亮灭
        let newFilter = filterButtons.index(of: sender)!
        selectFilter(filter: newFilter, forBand: bandSelected)
    }
    
    func selectFilter(filter: Int, forBand band: Int) {
        
        let newFilter = filter
        
        let offImage = UIImage(named: "eq_图形\(oldFilter + 1)_off")
        filterButtons[oldFilter].setImage(offImage, for: .normal)
        
        // 只有当 band 处于开启状态才调整
        if bands[band].isOn {
            bands[band].filterSelected = filter
            let onImage = UIImage(named: "eq_图形\(newFilter + 1)_band\(band + 1)")
            filterButtons[bands[band].filterSelected].setImage(onImage, for: .normal)
            oldFilter = newFilter
        }
        updateFilterControl()
        updateResponseView()
    }
    
    // 启用或关闭某频带
    func toggleBand(sender: UIButton) {
        let index = bandPowerBuutons.index(of: sender)!
        bands[index].isOn = !bands[index].isOn
        if bands[index].isOn == true {
            let powerButtonImage = UIImage(named: "eq_band\(index + 1)图标")
            sender.setImage(powerButtonImage, for: .normal)
            let bandImage = UIImage(named: "eq_Band\(index + 1)")
            bandSelectingButtons[index].setImage(bandImage, for: .normal)
        } else {
            let powerButtonImage = UIImage(named: "eq_band图标_off")
            sender.setImage(powerButtonImage, for: .normal)
            let bandImage = UIImage(named: "eq_Band\(index + 1)_off")
            bandSelectingButtons[index].setImage(bandImage, for: .normal)
        }
        if index == bandSelected {
            // 这个方法里会更新 resoponse view
            selectFilter(filter: bands[index].filterSelected, forBand: index)
            return
        }
        updateResponseView()
    }
    
    func dragFreqHandler(gr: UIPanGestureRecognizer){
        if gr.state == .began {
            initialFreqHandlerXMin = freqSliderHandler.frame.minX
            initialFreqMaskXMin = freqMaskLayer.frame.minX
        } else if gr.state == .changed {
            freqHandlerMovingDistance = gr.translation(in: view).x + initialFreqHandlerXMin
            if freqHandlerMovingDistance < 730 / 2 {
                freqHandlerMovingDistance = 730 / 2
            } else if freqHandlerMovingDistance > 1176 / 2 {
                freqHandlerMovingDistance = 1176 / 2
            }
            bands[bandSelected].freq = exp(Float((freqHandlerMovingDistance - 730 / 2)) / freqK + log(20))
            updateFreqSlider()
            updateResponseView()
        }
    }
    
    func dragGainHandler(gr: UIPanGestureRecognizer){
        if gr.state == .began {
            initialGainHandlerXMin = gainSliderHandler.frame.minX
            initialGainMaskXMin = gainMaskLayer.frame.minX
        } else if gr.state == .changed {
            gainHandlerMovingDistance = gr.translation(in: view).x + initialGainHandlerXMin
            if gainHandlerMovingDistance < 730 / 2 {
                gainHandlerMovingDistance = 730 / 2
            }
            else if gainHandlerMovingDistance > 1176 / 2 {
                gainHandlerMovingDistance = 1176 / 2
            }
            bands[bandSelected].gain = Float((gainHandlerMovingDistance - 730 / 2)) / gainK - 20
            updateGainSlider()
            updateResponseView()
        }
    }
    
    // 选中某个频带后所做的调整
    func selectBand(sender: UIButton) {
        
        let newBand = bandSelectingButtons.index(of: sender)!
        
        bandSelected = newBand
        
        selectFilter(filter: bands[newBand].filterSelected, forBand: newBand)
        // 更新线框
        updateBandLine()
        
    }
    
    // 拖动 Q 旋钮后所做的调整
    func dragQRotator(gr: UIPanGestureRecognizer ) {
        if gr.state == .began {
            let band = bands[bandSelected]
            initialQ = band.qValue
        } else if gr.state == .changed {
            if initialQ != nil {
                let band = bands[bandSelected]
                let dy = -gr.translation(in: view).y
                band.qValue = initialQ + Float(dy) * band.qUnit
                qValueLabel.text = String.init(format: "%.2f", band.qValue)
                updateRotator()
                updateResponseView()
            }
        }
    }
    
    func toggleMasterSwitch() {
        if eqIsOn {
            turnOffMasterSwitch()
        } else {
            turnOnMasterSwitch()
        }
    }
    
    private func turnOffMasterSwitch() {
        for i in 0 ..< bandPowerBuutons.count {
            if bands[i].isOn {
                previousBandsOn.append(i)
                toggleBand(sender: bandPowerBuutons[i])
            }
            bandPowerBuutons[i].isEnabled = false
        }
        let image = UIImage(named: "eq_OFF")
        masterSwitch.setImage(image, for: .normal)
        eqIsOn = false
    }
    
    private func turnOnMasterSwitch() {
        for i in 0 ..< bandPowerBuutons.count {
            if !bands[i].isOn && previousBandsOn.contains(i) {
                toggleBand(sender: bandPowerBuutons[i])
            }
            bandPowerBuutons[i].isEnabled = true
        }
        let image = UIImage(named: "eq_ON")
        masterSwitch.setImage(image, for: .normal)
        previousBandsOn = []
        eqIsOn = true
    }
    
    
    // MARK: - 更新
    
    // 更新所有控件
    private func updateFilterControl() {
        updateRotator()
        updateFreqSlider()
        updateGainSlider()
    }
    
    // 更新线框
    private func updateBandLine() {
        bandLineView.image = bandLineImages[bandSelected]
    }
    
    // 更新旋钮状态
    private func updateRotator() {
        let band = bands[bandSelected]
        let level = band.qLevel
        if band.isOn {
            rotatorImageView.isUserInteractionEnabled = true
            rotatorImageView.image = qRotatorImage[level]
            qValueLabel.textColor = mainColor
            qValueLabel.text = String.init(format: "%.2f", band.qValue)
            qLabel.textColor = mainColor
        } else {
            rotatorImageView.isUserInteractionEnabled = false
            rotatorImageView.image = qRotatorOffImage[level]
            qValueLabel.textColor = offColor
            qValueLabel.text = String.init(format: "%.2f", band.qValue)
            qLabel.textColor = offColor
        }
    }
    
    private func updateFreqSlider() {
        let band = bands[bandSelected]
        if band.isOn {
            freqTitleLabel.alpha = 1
            
            freqValueLabel.alpha = 1
            let value = band.freq
            if value < 100 {
                freqValueLabel.text = String.init(format: "%.1fHz", value)
            } else if value < 1000 {
                freqValueLabel.text = String.init(format: "%.0fHz", value)
            } else if value < 10000 {
                freqValueLabel.text = String.init(format: "%.2fkHz", value / 1000)
            } else {
                freqValueLabel.text = String.init(format: "%.1fkHz", value / 1000)
            }
            
            let backgroundImage = UIImage(named: "eq_拖动条")
            freqSliderBackground.image = backgroundImage
            
            let barImage = UIImage(named: "eq_拖动进度\(bandSelected + 1)")
            freqSliderBar.image = barImage
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            freqMaskLayer.frame = CGRect(x: -freqMaskLayer.bounds.maxX + 5 + CGFloat(freqK * (log(value) - log(20))), y: 0, width: freqMaskLayer.bounds.width, height: freqMaskLayer.bounds.height)
            CATransaction.commit()
            
            let handlerImage = UIImage(named: "eq_拖动\(bandSelected + 1)")
            freqSliderHandler.image = handlerImage
            freqSliderHandler.frame = CGRect(origin: CGPoint(x: 730 / 2 + CGFloat(freqK * (log(value) - log(20))), y: 684 / 2), size: freqSliderHandler.frame.size)
            
            freqSliderHandler.isUserInteractionEnabled = true
            
        } else {
            freqTitleLabel.alpha = 0.5
            
            freqValueLabel.alpha = 0.5
            let value = band.freq
            if value < 100 {
                freqValueLabel.text = String.init(format: "%.1fHz", value)
            } else if value < 1000 {
                freqValueLabel.text = String.init(format: "%.0fHz", value)
            } else if value < 10000 {
                freqValueLabel.text = String.init(format: "%.2fkHz", value / 1000)
            } else {
                freqValueLabel.text = String.init(format: "%.1fkHz", value / 1000)
            }
            
            let backgroundImage = UIImage(named: "eq_拖动条_off")
            freqSliderBackground.image = backgroundImage
            
            let barImage = UIImage(named: "eq_拖动进度_off")
            freqSliderBar.image = barImage
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            freqMaskLayer.frame = CGRect(x: -freqMaskLayer.bounds.maxX + 5 + CGFloat(freqK * (log(value) - log(20))), y: 0, width: freqMaskLayer.bounds.width, height: freqMaskLayer.bounds.height)
            CATransaction.commit()
            
            let handlerImage = UIImage(named: "eq_拖动_off")
            freqSliderHandler.image = handlerImage
            freqSliderHandler.frame = CGRect(origin: CGPoint(x: 730 / 2 + CGFloat(freqK * (log(value) - log(20))), y: 684 / 2), size: freqSliderHandler.frame.size)
            
            freqSliderHandler.isUserInteractionEnabled = false
        }
    }
    
    private func updateGainSlider() {
        let band = bands[bandSelected]
        if band.isOn && band.filterSelected != 0 && band.filterSelected != 4 {
            gainTitleLabel.alpha = 1
            
            gainValueLabel.alpha = 1
            let value = band.gain
            if value < 10 && value > -10 {
                gainValueLabel.text = String.init(format: "%.2fdB", value)
            } else {
                gainValueLabel.text = String.init(format: "%.1fdB", value )
            }
            
            let backgroundImage = UIImage(named: "eq_拖动条")
            gainSliderBackground.image = backgroundImage
            
            let barImage = UIImage(named: "eq_拖动进度\(bandSelected + 1)")
            gainSliderBar.image = barImage
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gainMaskLayer.frame = CGRect(x: -gainMaskLayer.bounds.maxX + 5 + CGFloat(gainK * (value + 20)), y: 0, width: gainMaskLayer.bounds.width, height: gainMaskLayer.bounds.height)
            CATransaction.commit()
            
            let handlerImage = UIImage(named: "eq_拖动\(bandSelected + 1)")
            gainSliderHandler.image = handlerImage
            gainSliderHandler.frame = CGRect(origin: CGPoint(x: 730 / 2 + CGFloat(gainK * (value + 20)), y: 794 / 2), size: gainSliderHandler.frame.size)
            
            gainSliderHandler.isUserInteractionEnabled = true
            
        } else {
            gainTitleLabel.alpha = 0.5
            
            gainValueLabel.alpha = 0.5
            let value = band.gain
            if value < 10 && value > -10 {
                gainValueLabel.text = String.init(format: "%.2fdB", value)
            } else {
                gainValueLabel.text = String.init(format: "%.1fdB", value )
            }
            
            let backgroundImage = UIImage(named: "eq_拖动条_off")
            gainSliderBackground.image = backgroundImage
            
            let barImage = UIImage(named: "eq_拖动进度_off")
            gainSliderBar.image = barImage
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gainMaskLayer.frame = CGRect(x: -gainMaskLayer.bounds.maxX + 5 + CGFloat(gainK * (value + 20)), y: 0, width: gainMaskLayer.bounds.width, height: gainMaskLayer.bounds.height)
            CATransaction.commit()
            
            let handlerImage = UIImage(named: "eq_拖动_off")
            gainSliderHandler.image = handlerImage
            gainSliderHandler.frame = CGRect(origin: CGPoint(x: 730 / 2 + CGFloat(gainK * (value + 20)), y: 794 / 2), size: gainSliderHandler.frame.size)
            
            gainSliderHandler.isUserInteractionEnabled = false
        }
    }
    
    private func updateResponseView() {
        var gp = Array<Float>.init(repeating: 0, count: pointNumber)
        for band in bands {
            if band.isOn {
                for i in 0 ..< band.response.count {
                    gp[i] += band.response[i]
                }
            }
        }
        responseView.drawResponseCurve(f: freqPoints, gain: gp)
    }
    
    
    // 画频响曲线的 view
    class ResponseView: UIView {
        // x: 频率（Hz），y: 增益(dB)
        private var points: [CGPoint] = []
        private var k1: CGFloat!
        private var k2: CGFloat!
        
        init(frame: CGRect, pointNumber: Int) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.clear
            self.clipsToBounds = true
            self.isOpaque = false
            self.clearsContextBeforeDrawing = true
            
            points = [CGPoint].init(repeating: CGPoint.zero, count: pointNumber)
            
            // x = k1 * (log(w) - log(20))
            // w = 20000 => x = bounds.maxX
            // => k1 = frame.bounds.maxX / (log(20000) - log(20)) = bounds.maxX / log(1000)
            k1 = self.bounds.maxX / log(1000)
            
            // y = -k2 * gain + midY
            k2 = bounds.maxY / 54.5
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func drawResponseCurve(f: [Float], gain: [Float]){
            
            for i in 0 ..< f.count {
                points[i] = CGPoint(x: k1 * CGFloat((log(f[i]) - log(20.0))), y: -k2 * CGFloat(gain[i]) + bounds.midY)
            }
            setNeedsDisplay()
        }
        override func draw(_ rect: CGRect) {
            if let context = UIGraphicsGetCurrentContext() {
                context.setStrokeColor(UIColor(red: 250.0/255, green: 180.0/255, blue: 183.0/255, alpha: 1).cgColor)
                context.setLineCap(.round)
                context.setLineWidth(2.0)
                context.addLines(between: points)
                context.strokePath()
            }
        }
    }
    
    
    
    
}

enum EP_Error: Error {
    case numbersOfTwoInputsNotEqual
}
