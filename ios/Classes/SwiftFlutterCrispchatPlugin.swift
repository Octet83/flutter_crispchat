import Flutter
import UIKit
import Crisp

public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin {
  init(_ binaryMessenger: FlutterBinaryMessenger) {
    onUpdateUnreadCountStream = FlutterStreamFactory(binaryMessenger, "onUpdateUnreadCount")
  }
  
  let onUpdateUnreadCountStream: FlutterStreamFactory
  
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.bottlepay.flutter_crispchat", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterCrispChatPlugin(registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method) {
    case "configure": configure(call, result: result)
    case "showChat": showChat(call, result: result)
    case "setUserDetails": setUserDetails(call, result: result)
    case "setCustomField": setCustomField(call, result: result)
    case "logout": logout(call, result: result)
      
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  public func configure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String : Any] else {
      result(FlutterError(code: "ARGUMENTS", message: "Invalid arguments supplied", details: nil))
      return
    }
    let websiteId = arguments["websiteId"] as! String
    
    CrispSDK.configure(websiteID: websiteId)
    Crisp.locale = "fr"
    result(nil)
  }
  
  public func showChat(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
      rootVC.present(ChatViewController(), animated: true)
      result(nil)
    } else {
      print("There is no root vc at the moment")
      result(FlutterError(code: "PLATFORM_ERROR", message: "No root VC available to present", details: nil))
    }
    
    result(nil)
  }
  
  public func setUserDetails(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String : Any] else {
      result(FlutterError(code: "ARGUMENTS", message: "Invalid arguments supplied", details: nil))
      return
    }
    let email = arguments["email"] as! String
    let nickname = arguments["nickname"] as! String
    let phone = arguments["phone"] as! String
    let avatarUrl = arguments["avatarUrl"] as! String
    //    let company = arguments["company"] as! String
    
    CrispSDK.user.email = email
    CrispSDK.user.nickname = nickname
    CrispSDK.user.phone = phone
    CrispSDK.user.avatar = URL(string: avatarUrl)
    //    CrispSDK.user.company = Company(name: <#T##String?#>, url: <#T##URL?#>, companyDescription: <#T##String?#>, employment: <#T##Employment?#>, geolocation: <#T##Geolocation?#>)
    result(nil)
  }
  
  public func setCustomField(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String : Any] else {
      result(FlutterError(code: "ARGUMENTS", message: "Invalid arguments supplied", details: nil))
      return
    }
    let key = arguments["key"] as! String
    let value = arguments["value"] as! String
    
    CrispSDK.session.setString(value, forKey: key)
    result(nil)
  }
  
  public func logout(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    CrispSDK.session.reset()
    result(nil)
  }
}

// Create a new flutter stream
public class FlutterStreamFactory: NSObject, FlutterStreamHandler {
  init(_ binaryMessenger: FlutterBinaryMessenger, _ streamName: String) {
    super.init()
    FlutterEventChannel(name: "com.bottlepay.flutter_crispchat/streams/\(streamName)", binaryMessenger: binaryMessenger).setStreamHandler(self)
  }
  
  // This is what events will be published to
  var sink: FlutterEventSink?
  
  // Called from dart to subscribe to the stream
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    return nil
  }
  
  // Called from dart to cancel a stream subscription
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }
}
