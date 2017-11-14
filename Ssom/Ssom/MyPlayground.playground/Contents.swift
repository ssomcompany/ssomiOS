//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

print (str)

let num = 26.357647368264

print ("\(num)")

let d = Date()

print(d)

let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

print(formatter.string(from: d))

let ss: CGFloat = 3.146738269874623 * 0.0001923729837
let sss: CGFloat = 3.1376498765938746

let point: CGPoint = CGPoint(x: ss, y: sss)

let re = point.x / sss