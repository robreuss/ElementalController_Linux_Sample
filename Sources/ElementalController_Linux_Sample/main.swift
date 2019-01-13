import Foundation
import ElementalController

let eid_forward: Int8 = 1
let eid_backward: Int8 = 2
let eid_right: Int8 = 3
let eid_left: Int8 = 4
let eid_speed: Int8 = 5

class Main {
    
    var elementalController = ElementalController()
    var serviceName = "robot"
    var clientDevices: [ClientDevice] = []
    
    func start() {
        
        ElementalController.loggerLogLevel = .Debug
        ElementalController.allowUDPService = true
        ElementalController.enableTransferAnalysis = true
        ElementalController.transferAnalysisFrequency = 10.0
        ElementalController.UDPBufferSize = 512 // Max message size - only send small elements!
        ElementalController.TCPBufferSize = 4096
        ElementalController.protocolFamily = .inet6
        
        elementalController.setupForService(serviceName: serviceName, displayName: "")
        
        self.elementalController.service.events.deviceConnected.handler = { _, device in
        
            let clientDevice = device as! ClientDevice
            self.clientDevices.append(clientDevice)
        
            let element_forward = clientDevice.attachElement(Element(identifier: eid_forward, displayName: "Forward", proto: .tcp, dataType: .Double))
            let element_backward = clientDevice.attachElement(Element(identifier: eid_backward, displayName: "Backward", proto: .tcp, dataType: .Double))
            let element_right = clientDevice.attachElement(Element(identifier: eid_right, displayName: "Right", proto: .tcp, dataType: .Double))
            let element_left = clientDevice.attachElement(Element(identifier: eid_left, displayName: "Left", proto: .tcp, dataType: .Double))
            let element_speed = clientDevice.attachElement(Element(identifier: eid_speed, displayName: "Speed", proto: .udp, dataType: .Float))
            
            element_forward.handler = { element, device in
            logDebug("Going forward: \(element.value ?? "Unknown Value")")
            }
            element_backward.handler = { element, device in
            logDebug("Going backward: \(element.value ?? "Unknown Value")")
            }
            element_right.handler = { element, device in
            logDebug("Going right: \(element.value ?? "Unknown Value")")
            }
            element_left.handler = { element, device in
            logDebug("Going left: \(element.value ?? "Unknown Value")")
            }
            element_speed.handler = { element, device in
                logDebug("Speed set to: \(element.value ?? "Unknown Value")")
            }

            self.elementalController.service.events.deviceDisconnected.handler = { _, _ in
                logDebug("Client device disconnected")
            }
        }
        
        self.elementalController.service.publish(onPort: 0)
        
    }
    
}

var process = Main()
process.start()
withExtendedLifetime((process)) {
    RunLoop.main.run()
}
