import Foundation
import ElementalController

// Element identifiers are transmitted as a unique Int8 with each
// element message to identify the element being sent or received.
// All other metadata about the element (datatype, displayname, handler
// protocol) is compiled into both sides.
let eid_forward: Int8 = 1
let eid_backward: Int8 = 2
let eid_right: Int8 = 3
let eid_left: Int8 = 4
let eid_speed: Int8 = 5
let eid_motionX: Int8 = 6
let eid_motionY: Int8 = 7
let eid_motionZ: Int8 = 8

class Main {
    
    // A reference to the framework instance.  If you wish to publish
    // more than one service, or act as the client of more than one service,
    // you'll want more than one of these.
    var elementalController = ElementalController()
    
    // This is used as part of the NetService name when the service
    // is published, and used as the basis of browsing
    var serviceName = "robot"
    
    // Keep references to all the client devices that connect.
    var clientDevices: [ClientDevice] = []
    
    func start() {
        
        ElementalController.loggerLogLevel = .Debug
        
        // You may wish to disable UDP if you don't need it or
        // or for security reasons
        ElementalController.allowUDPService = true
        
        // This will show periodic transfer statistics in the console
        ElementalController.enableTransferAnalysis = true
        ElementalController.transferAnalysisFrequency = 10.0 // in seconds
        
        // UDP should only be used for small messages like Floats and Doubles
        // Minimize the size of the buffer
        ElementalController.UDPBufferSize = 512
        ElementalController.TCPBufferSize = 4096
        
        // Determines if networking occurs over IPv4 or IPv6
        ElementalController.protocolFamily = .inet6
        
        // Initialize the service so we can add handlers and elements
        elementalController.setupForService(serviceName: serviceName, displayName: "")
        
        // For each device that connects, add elements and handlers
        self.elementalController.service.events.deviceConnected.handler = { _, device in
            
            // Keep track of these
            let clientDevice = device as! ClientDevice
            self.clientDevices.append(clientDevice)
            
            // Attach elements to the client device.  Note, it's possible to publish more than one service, and have
            // different sets of elements, as well it is possible to have different sets of elements on
            // a client device basis (if you should so need for some unknown use case)
            let elementForward = clientDevice.attachElement(Element(identifier: eid_forward, displayName: "Forward", proto: .tcp, dataType: .Double))
            let elementBackward = clientDevice.attachElement(Element(identifier: eid_backward, displayName: "Backward", proto: .tcp, dataType: .Double))
            let elementRight = clientDevice.attachElement(Element(identifier: eid_right, displayName: "Right", proto: .tcp, dataType: .Double))
            let elementLeft = clientDevice.attachElement(Element(identifier: eid_left, displayName: "Left", proto: .tcp, dataType: .Double))
            let elementSpeed = clientDevice.attachElement(Element(identifier: eid_speed, displayName: "Speed", proto: .udp, dataType: .Float))
            let elementMotionX = clientDevice.attachElement(Element(identifier: eid_motionX, displayName: "Motion X", proto: .udp, dataType: .Double))
            let elementMotionY = clientDevice.attachElement(Element(identifier: eid_motionY, displayName: "Motion Y", proto: .udp, dataType: .Double))
            let elementMotionZ = clientDevice.attachElement(Element(identifier: eid_motionZ, displayName: "Motion Z", proto: .udp, dataType: .Double))
            
            // Define our handler one time and apply it to muliple elements
            let directionHandler: Element.ElementHandler = { element, device in
                logDebug("\(element.displayName): \(element.value ?? "Unknown Value")")
            }
            // Actions taken on incoming elements
            elementForward.handler = directionHandler
            elementBackward.handler = directionHandler
            elementRight.handler = directionHandler
            elementLeft.handler = directionHandler
            elementSpeed.handler = directionHandler
            
            // Rounded motion values.  If these needed to be received as a tuple, they could
            // be serialized into a Data data-type element on the client-side and deserialized
            // here.
            let rounding = 1000.0
            
            // Handler common to all three axis
            let motionHandler: Element.ElementHandler = { element, device in
                var value = ((element.value as! Double) * rounding).rounded() / rounding
                logDebug("\(element.displayName): \(value)")
            }
            elementMotionX.handler = motionHandler
            elementMotionY.handler = motionHandler
            elementMotionZ.handler = motionHandler
            
            self.elementalController.service.events.deviceDisconnected.handler = { _, _ in
                logDebug("Client device disconnected")
            }
        }
        
        // Finally, publish the service
        self.elementalController.service.publish(onPort: 0)
        
    }
    
}

// Setup a long running process
var process = Main()
process.start()
withExtendedLifetime((process)) {
    RunLoop.main.run()
}
