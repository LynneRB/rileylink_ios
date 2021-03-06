//
//  ReadSettingsCarelinkMessageBody.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 12/26/15.
//  Copyright © 2015 Nathan Racklyeft. All rights reserved.
//

import Foundation


public enum BasalProfile {

    case standard
    case profileA
    case profileB

    init(rawValue: UInt8) {
        switch rawValue {
        case 1:
            self = .profileA
        case 2:
            self = .profileB
        default:
            self = .standard
        }
    }
}


/**
 Describes the response to the Read Settings command from the pump

 See: [Decocare Class](https://github.com/bewest/decoding-carelink/blob/master/decocare/commands.py#L1223)
 ```
 -- ------ -- 00 01 02 03 04 05 06 07 0809 10 11 12 13141516171819 20 21 2223 24 25 26 27 282930313233 343536 --
 a7 594040 c0 19 00 01 00 01 01 00 96 008c 00 00 00 00000064010400 14 00 1901 01 01 00 00 000000000000 000000 00000000000000000000000000000000000000000000000000000000 e9
 ```
 */
public class ReadSettingsCarelinkMessageBody: CarelinkLongMessageBody {
    private static let maxBolusMultiplier: Double = 10
    private static let maxBasalMultiplier: Double = 40

    public let maxBasal: Double
    public let maxBolus: Double

    public let insulinActionCurveHours: Int

    public let selectedBasalProfile: BasalProfile

    public required init?(rxData: Data) {
        guard rxData.count == type(of: self).length else {
            return nil
        }
        
        let newer = rxData[0] == 25 // x23

        let maxBolusTicks: UInt8
        let maxBasalTicks: Int
        
        if newer {
            maxBolusTicks = rxData[7]
            maxBasalTicks = Int(bigEndianBytes: rxData.subdata(in: 8..<10))
        } else {
            maxBolusTicks = rxData[6]
            maxBasalTicks = Int(bigEndianBytes: rxData.subdata(in: 7..<9))
        }
        maxBolus = Double(maxBolusTicks) / type(of: self).maxBolusMultiplier
        maxBasal = Double(maxBasalTicks) / type(of: self).maxBasalMultiplier

        let rawSelectedBasalProfile: UInt8 = rxData[12]
        selectedBasalProfile = BasalProfile(rawValue: rawSelectedBasalProfile)

        let rawInsulinActionCurveHours: UInt8 = rxData[18]
        insulinActionCurveHours = Int(rawInsulinActionCurveHours)

        super.init(rxData: rxData)
    }

    public required init?(rxData: NSData) {
        fatalError("init(rxData:) has not been implemented")
    }
}


extension ReadSettingsCarelinkMessageBody: DictionaryRepresentable {
    public var dictionaryRepresentation: [String: Any] {
        return [:]
    }
}
