//
//  StringExtensions.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 12/07/16.
//  Copyright © 2016 Probir Chakraborty. All rights reserved.
//

import Foundation
import UIKit


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    
    func splitByLength(_ length: Int) -> [String] {
        var result = [String]()
        var collectedCharacters = [Character]()
        collectedCharacters.reserveCapacity(length)
        var count = 0
        
        for character in self.characters {
            collectedCharacters.append(character)
            count += 1
            if (count == length) {
                // Reached the desired length
                count = 0
                result.append(String(collectedCharacters))
                collectedCharacters.removeAll(keepingCapacity: true)
            }
        }
        
        // Append the remainder
        if !collectedCharacters.isEmpty {
            result.append(String(collectedCharacters))
        }
        
        return result
    }
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }

    func contains(_ string: String) -> Bool {
        return self.range(of: string) != nil
    }
    
    func substringFromIndex(_ index: Int) -> String {
        if (index < 0 || index > self.count) {
            //print("index \(index) out of bounds")
            return ""
        }
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: index))
    }
    
    func substringToIndex(_ index: Int) -> String {
        if (index < 0 || index > self.count) {
            //print("index \(index) out of bounds")
            return ""
        }
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: index))
    }
    
    func trimWhiteSpace () -> String {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmedString
    }
    
    func isValidMobileNumber() -> Bool {
        let mobileNoRegEx = "^((\\+)|(00)|(\\*)|())[0-9]{8,14}((\\#)|())$"
        let mobileNoTest = NSPredicate(format:"SELF MATCHES %@", mobileNoRegEx)
        return mobileNoTest.evaluate(with: self)
    }
    
    func isContainsAllZeros() -> Bool {
        let mobileNoRegEx = "^0*$";
        let mobileNoTest = NSPredicate(format:"SELF MATCHES %@", mobileNoRegEx)
        return mobileNoTest.evaluate(with: self)
    }

     func isValidUserName() -> Bool {
        let nameRegEx = "^[a-zA-Z0-9\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let passwordRegEx = "^[A-Za-z0-9]+(?=.*?)(?=.*?[#?!@$%^&*-]),{8,16}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }

    func isEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        print(emailTest.evaluate(with: self))
        return emailTest.evaluate(with: self)
    }
    
    func isContainsAtleastOneSpecialCharacters() -> Bool{
        let passwordRegEx = "^(?=.*?[$@$!%*#?&^)(]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    
    func containsAlphaNumericOnly() -> Bool {
        let nameRegEx = "^[a-zA-Z0-9\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func containsNumberOnly() -> Bool {
        let nameRegEx = "^[0-9]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    

    func containsFourLettersAndTwoDigits() -> Bool {
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Za-z].*[A-Za-z].*[A-Za-z].*[A-Za-z])(?=.*[0-9].*[0-9]).{8,}")
        return passwordTest.evaluate(with: self)
    }
    
    func containsAlphabetsOnly() -> Bool {
        let nameRegEx = "^[a-zA-Z]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func isValidName() -> Bool {
        
        let nameRegEx = "^[a-zA-Z\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    var length: Int {
        return self.count
    }
    
    func dateFromString(_ format:String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            print("Unable to format date")
        }
        
        return nil
    }
    
//    func md5() -> String {
//        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
//            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
//        }
//        
//        var digestHex = ""
//        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
//            digestHex += String(format: "%02x", digest[index])
//        }
//        
//        return digestHex
//    }
    
    //>>>> removes all whitespace from a string, not just trailing whitespace <<<//
    func removeWhitespace() -> String {
        return self.replaceString(" ", withString: "")
    }
    
    //>>>> Replacing String with String <<<//
    func replaceString(_ string:String, withString:String) -> String {
        return self.replacingOccurrences(of: string, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    
    
    func getAttributedString(_ string_to_Attribute:String, color:UIColor, font:UIFont) -> NSAttributedString {
        
        let range = (self as NSString).range(of: string_to_Attribute)
        
        let attributedString = NSMutableAttributedString(string:self)
        
        // multiple attributes declared at once
        let multipleAttributes = [
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.font: font,
            ]
        
        attributedString.addAttributes(multipleAttributes, range: range)
        
        return attributedString.mutableCopy() as! NSAttributedString
    }

}
