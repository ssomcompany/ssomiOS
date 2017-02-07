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