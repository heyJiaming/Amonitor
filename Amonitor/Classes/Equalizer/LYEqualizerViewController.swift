//
//  LYEqualizerViewController.swift
//  Amonitor
//
//  Created by 乐野 on 2016/12/22.
//  Copyright © 2016年 leye. All rights reserved.
//

import UIKit
import Accelerate

@objc(LYEqualizerViewController)

class LYEqualizerViewController: UIViewController {
    
    // 一些常数
    private let mainColor = UIColor(red: 254.0 / 255, green: 180.0 / 255, blue: 183.0 / 255, alpha: 1)
    private let offColor = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 239.0 / 255, alpha: 1)
    private let pointNumber = 2048
    static let Fs: Float = 44100
    
    // 频带信息
    private var bands: [BandInformation] = []
    
    // 选中的频带（0~4）
    private var bandSelected: Int = 0
    
    // 各个按钮及修饰
    private var filterButtons: [UIButton] = []
    private var oldFilter: Int = 0
    private var bandSelectingButtons: [UIButton] = []
    private var bandLineView: UIImageView!
    private var bandLineImages: [UIImage] = []
    private var bandPowerBuutons: [UIButton] = []
    
    // Q值旋钮
    private var qRotatorImage: [UIImage] = []
    private var qRotatorOffImage: [UIImage] = []
    private var rotatorImageView: UIImageView!
    private var qValueLabel: UILabel!
    private var qLabel: UILabel!
    private var initialQ: Float!
    
    // 延迟绘画
    private var isDrawing = false
    
    // 画频响曲线的view
    private var responseView: ResponseView!
    
    // 计算频响曲线的类
    private var ep_response: EP_Response!
    
    // 频率滑动条
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
    
    // 增益滑动条
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
        
        setDefaultBands()
        
        setBackground()
        
        setFilterButtons()
        
        setQRotator()
        
        setEP_Response()
        
        setResponseView()
        
        setBandButtons()
        
        setFreqSlider()
        
        setGainSlider()
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
        view.addSubview(responseView)
    }
    
    private func setEP_Response() {
        ep_response = EP_Response(pointNumber: self.pointNumber)
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
            drawBands(bandsToDraw: [bandSelected])
        }
        updateFilterControl()
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
        selectFilter(filter: bands[index].filterSelected, forBand: index)
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
            drawBands(bandsToDraw: [bandSelected])
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
            drawBands(bandsToDraw: [bandSelected])
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
                drawBands(bandsToDraw: [bandSelected])
            }
        }
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
    
    private func drawBands(bandsToDraw: [Int]) {
        
            for i in bandsToDraw {
                let (b, a) = bands[i].returnBandA()
                var fp: [Float] = []
                var gp: [Float] = []
                do {
                    (fp, gp) = try ep_response.freqz(b: b, a: a)
                } catch {
                    
                }
                responseView.drawResponseCurve(f: fp, gain: gp)
            
        }
    }
    
    // MARK: - 测试
    private func testResponseView() {
//        let w: [CGFloat] = [20.0, 40.0, 200.0, 400.0, 2000.0, 4000.0, 20000.0]
//        let gain: [CGFloat] = [2, 4, 6, 8, 10, 12, 14]
        
//        let w: [CGFloat] = [200.0]
//        let gain: [CGFloat] = [0]
        
        let f: [Float] = [20.0, 200, 2000.0, 20000.0]
        let gain: [Float] = [5, 10, 15, 20]
        responseView.drawResponseCurve(f: f, gain: gain)
    }
    
    private func testDFT() {
        
        var numbersA: [Float] = []
        var numbersB: [Float] = []
        var result: [Float] = []


        numbersA = [1.0, -3.5794348, 5.6586672, -4.9654152, 2.5294949, -0.70527411, 0.08375648]
        numbersB = [0.28940692, -1.7364415, 4.3411038, -5.7881383, 4.3411038, -1.7364415, 0.28940692]
 
        print("\n64 results")
        let ep_response = EP_Response(pointNumber: 64)
        do {
            result = try ep_response.freqz(b: numbersB, a: numbersA).1
        } catch EP_Error.numbersOfTwoInputsNotEqual {
            print("the length of two inputs are not the same")
        } catch {
            
        }
        for number in result {
            print(number)
        }
        print()
        
        print("\n128 results")
        let ep_response2 = EP_Response(pointNumber: 128)
        do {
            result = try ep_response2.freqz(b: numbersB, a: numbersA).1
        } catch EP_Error.numbersOfTwoInputsNotEqual {
            print("the length of two inputs are not the same")
        } catch {
            
        }
        for number in result {
            print(number)
        }
        print()
    }
    
    
    // MARK: - 自定义内部类
    // 频带信息
    class BandInformation: NSObject {
        // 是否开启了这个频带的滤波
        var isOn: Bool = false
        // 选择的滤波器（0~4）
        var filterSelected: Int = 0
        // 五个滤波器
        var filters: [FilterInformation] = []
        
        var freq: Float {
            set {
                filters[filterSelected].freq = newValue
            }
            get {
                return filters[filterSelected].freq
            }
        }
        
        var gain: Float {
            set {
                filters[filterSelected].gain = newValue
            }
            get {
                if filterSelected == 0 || filterSelected == 4 {return 0}
                return filters[filterSelected].gain
            }
        }
        
        var qValue: Float {
            set {
                filters[filterSelected].qValue = newValue
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
        }
        
        func returnBandA() -> ([Float], [Float]) {
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
            var freq: Float = 20.0 {
                didSet {
                    if freq < 20 {freq = 20}
                    else if freq > 20000 {freq = 20000}
                }
            }
            var gain: Float = 0 {
                didSet {
                    if gain < -20 {gain = -20}
                    else if gain > 20 {gain = 20}
                }
            }
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
                context.setStrokeColor(UIColor.red.cgColor)
                context.setLineCap(.round)
                context.setLineWidth(2.0)
                context.addLines(between: points)
                context.strokePath()
            }
        }
    }
    
    // 计算频响曲线的类
    class EP_Response: NSObject {
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
    
    
}

enum EP_Error: Error {
    case numbersOfTwoInputsNotEqual
}
