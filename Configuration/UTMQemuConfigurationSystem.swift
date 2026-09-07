//
// Copyright © 2022 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Settings specific to the SHARP Brain machine (`-machine brain` in qemu-brain).
///
/// Every field maps one-to-one to a machine property registered by
/// `brain_instance_init()` in qemu-brain's `hw/arm/mxs.c`, and the defaults
/// here are the same defaults QEMU uses, so an untouched configuration
/// produces no extra `-machine` properties at all.
struct UTMQemuConfigurationBrain: Codable {
    /// `'eboot'` jumps straight into EBOOT, `'full'` also runs the XLDR DDR init.
    var bootMode: String = "eboot"

    /// Faithful hardware mode. Off means every QEMU-only guest aid is re-enabled.
    var isStrictHw: Bool = true

    /// Extra logging from the ROM/XLDR stage.
    var isRomVerbose: Bool = true

    /// Attach a NAND device to the GPMI controller (the real socket is empty).
    var hasGpmiNand: Bool = false

    /// Raw image backing the GPMI NAND media. Needs `hasGpmiNand`.
    var gpmiNandFileName: String?

    /// QEMU-only aid: remap the FMD Region 4 window onto the real FAT32 partition.
    var isAidRegion4Remap: Bool = false

    /// QEMU-only aid: after eMMC boot, scan the SD card for a launcher and run it.
    var isAidSdLauncher: Bool = false

    /// QEMU-only aid: ignore unmapped/aborted memory transactions.
    var isAidIgnoreBusErr: Bool = false

    /// Fault-injection experiment: first sector of the zone.
    var expFaultStart: Int = 0

    /// Fault-injection experiment: zone length in sectors.
    var expFaultLen: Int = 0

    /// Fault-injection experiment: 0=off 1=read-error 2=read-delay 3=trace-only.
    var expFaultMode: Int = 0

    /// Fault-injection experiment: virtual-time delay per zone read in mode 2.
    var expFaultDelayUs: Int = 500000

    /// Guest framebuffer width. The panel is a 480x854 portrait module.
    var lcdWidth: Int = 480

    /// Guest framebuffer height.
    var lcdHeight: Int = 854

    /// Degrees the panel is physically mounted (90 gives the landscape picture).
    var lcdRotate: Int = 90

    enum CodingKeys: String, CodingKey {
        case bootMode = "BootMode"
        case isStrictHw = "StrictHw"
        case isRomVerbose = "RomVerbose"
        case hasGpmiNand = "GpmiNand"
        case gpmiNandFileName = "GpmiNandFile"
        case isAidRegion4Remap = "AidRegion4Remap"
        case isAidSdLauncher = "AidSdLauncher"
        case isAidIgnoreBusErr = "AidIgnoreBusErr"
        case expFaultStart = "ExpFaultStart"
        case expFaultLen = "ExpFaultLen"
        case expFaultMode = "ExpFaultMode"
        case expFaultDelayUs = "ExpFaultDelayUs"
        case lcdWidth = "LcdWidth"
        case lcdHeight = "LcdHeight"
        case lcdRotate = "LcdRotate"
    }

    init() {
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bootMode = try values.decodeIfPresent(String.self, forKey: .bootMode) ?? "eboot"
        isStrictHw = try values.decodeIfPresent(Bool.self, forKey: .isStrictHw) ?? true
        isRomVerbose = try values.decodeIfPresent(Bool.self, forKey: .isRomVerbose) ?? true
        hasGpmiNand = try values.decodeIfPresent(Bool.self, forKey: .hasGpmiNand) ?? false
        gpmiNandFileName = try values.decodeIfPresent(String.self, forKey: .gpmiNandFileName)
        isAidRegion4Remap = try values.decodeIfPresent(Bool.self, forKey: .isAidRegion4Remap) ?? false
        isAidSdLauncher = try values.decodeIfPresent(Bool.self, forKey: .isAidSdLauncher) ?? false
        isAidIgnoreBusErr = try values.decodeIfPresent(Bool.self, forKey: .isAidIgnoreBusErr) ?? false
        expFaultStart = try values.decodeIfPresent(Int.self, forKey: .expFaultStart) ?? 0
        expFaultLen = try values.decodeIfPresent(Int.self, forKey: .expFaultLen) ?? 0
        expFaultMode = try values.decodeIfPresent(Int.self, forKey: .expFaultMode) ?? 0
        expFaultDelayUs = try values.decodeIfPresent(Int.self, forKey: .expFaultDelayUs) ?? 500000
        lcdWidth = try values.decodeIfPresent(Int.self, forKey: .lcdWidth) ?? 480
        lcdHeight = try values.decodeIfPresent(Int.self, forKey: .lcdHeight) ?? 854
        lcdRotate = try values.decodeIfPresent(Int.self, forKey: .lcdRotate) ?? 90
    }
}

/// Basic hardware settings.
struct UTMQemuConfigurationSystem: Codable {
    /// The QEMU architecture to emulate.
    var architecture: QEMUArchitecture = .x86_64
    
    /// The QEMU machine target to emulate.
    var target: any QEMUTarget = QEMUTarget_x86_64.q35
    
    /// The QEMU CPU to emulate. Note that `default` will use the default CPU for the architecture.
    var cpu: any QEMUCPU = QEMUCPU_x86_64.default
    
    /// Optional list of CPU flags to add to the target CPU.
    var cpuFlagsAdd: [any QEMUCPUFlag] = []
    
    /// Optional list of CPU flags to remove from the defaults of the target CPU. Parsed after `cpuFlagsAdd`.
    var cpuFlagsRemove: [any QEMUCPUFlag] = []
    
    /// Number of CPU cores to emulate. Set to 0 to match the number of available cores on the host.
    var cpuCount: Int = 0
    
    /// Set to true to force emulation on multiple cores even when the results may be incorrect.
    var isForceMulticore: Bool = false
    
    /// The RAM of the guest in MiB.
    var memorySize: Int = 512
    
    /// The JIT cache (code cache) in MiB.
    var jitCacheSize: Int = 0

    /// Settings for the SHARP Brain machine. Ignored for every other target.
    var brain: UTMQemuConfigurationBrain = UTMQemuConfigurationBrain()
    
    enum CodingKeys: String, CodingKey {
        case architecture = "Architecture"
        case target = "Target"
        case cpu = "CPU"
        case cpuFlagsAdd = "CPUFlagsAdd"
        case cpuFlagsRemove = "CPUFlagsRemove"
        case cpuCount = "CPUCount"
        case isForceMulticore = "ForceMulticore"
        case memorySize = "MemorySize"
        case jitCacheSize = "JITCacheSize"
        case brain = "Brain"
    }
    
    init() {
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        architecture = try values.decode(QEMUArchitecture.self, forKey: .architecture)
        target = try values.decode(architecture.targetType, forKey: .target)
        do {
            cpu = try values.decode(architecture.cpuType, forKey: .cpu)
        } catch UTMConfigurationError.invalidConfigurationValue(let value) {
            logger.warning("Unable to decode CPU '\(value)', resetting to default CPU")
            cpu = architecture.cpuType.default
        }
        cpuFlagsAdd = try values.decode([AnyQEMUConstant].self, forKey: .cpuFlagsAdd)
        cpuFlagsRemove = try values.decode([AnyQEMUConstant].self, forKey: .cpuFlagsRemove)
        cpuCount = try values.decode(Int.self, forKey: .cpuCount)
        isForceMulticore = try values.decode(Bool.self, forKey: .isForceMulticore)
        memorySize = try values.decode(Int.self, forKey: .memorySize)
        jitCacheSize = try values.decode(Int.self, forKey: .jitCacheSize)
        brain = try values.decodeIfPresent(UTMQemuConfigurationBrain.self, forKey: .brain) ?? UTMQemuConfigurationBrain()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(architecture, forKey: .architecture)
        try container.encode(target.asAnyQEMUConstant(), forKey: .target)
        try container.encode(cpu.asAnyQEMUConstant(), forKey: .cpu)
        try container.encode(cpuFlagsAdd.map({ flag in flag.asAnyQEMUConstant() }), forKey: .cpuFlagsAdd)
        try container.encode(cpuFlagsRemove.map({ flag in flag.asAnyQEMUConstant() }), forKey: .cpuFlagsRemove)
        try container.encode(cpuCount, forKey: .cpuCount)
        try container.encode(isForceMulticore, forKey: .isForceMulticore)
        try container.encode(memorySize, forKey: .memorySize)
        try container.encode(jitCacheSize, forKey: .jitCacheSize)
        try container.encode(brain, forKey: .brain)
    }
}

// MARK: - Conversion of old config format

extension UTMQemuConfigurationSystem {
    init(migrating oldConfig: UTMLegacyQemuConfiguration) {
        self.init()
        if let archStr = oldConfig.systemArchitecture, let arch = QEMUArchitecture(rawValue: archStr) {
            architecture = arch
        }
        if let targetStr = oldConfig.systemTarget {
            target = architecture.targetType.init(rawValue: targetStr) ?? architecture.targetType.default
        }
        if let cpuStr = oldConfig.systemCPU {
            cpu = architecture.cpuType.init(rawValue: cpuStr) ?? architecture.cpuType.default
        }
        if let cpuCountNum = oldConfig.systemCPUCount {
            cpuCount = cpuCountNum.intValue
        }
        if let oldFlags = oldConfig.systemCPUFlags {
            for oldFlag in oldFlags {
                var newFlag = oldFlag
                let isAdd: Bool
                if oldFlag.starts(with: "-") {
                    newFlag.removeFirst()
                    isAdd = false
                } else if oldFlag.starts(with: "+") {
                    newFlag.removeFirst()
                    isAdd = true
                } else {
                    isAdd = true
                }
                let flag = AnyQEMUConstant(rawValue: newFlag)!
                if isAdd {
                    cpuFlagsAdd.append(flag)
                } else {
                    cpuFlagsRemove.append(flag)
                }
            }
        }
        isForceMulticore = oldConfig.systemForceMulticore
        if let memoryNum = oldConfig.systemMemory {
            memorySize = memoryNum.intValue
        }
        if let jitCacheNum = oldConfig.systemJitCacheSize {
            jitCacheSize = jitCacheNum.intValue
        }
    }
}
