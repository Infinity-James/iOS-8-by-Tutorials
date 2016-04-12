//  KeyboardThemeData.swift

/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import UIKit

let ThemePreference: String = "pref_theme"

let ButtonFontName = "Helvetica"
let ButtonFontSize: CGFloat = 16.0
let SpecialButtonFontSize: CGFloat = 12.0

class KeyboardThemeData: NSObject {
  
  var themeID: Int = 0
  var themeName: String = ""
  
  var colorForBackground: UIColor = UIColor.clearColor()
  var colorForCustomRow: UIColor = UIColor.clearColor()
  var colorForRow1: UIColor = UIColor.clearColor()
  var colorForRow2: UIColor = UIColor.clearColor()
  var colorForRow3: UIColor = UIColor.clearColor()
  var colorForRow4: UIColor = UIColor.clearColor()
  
  var colorForButtonFont: UIColor = UIColor.clearColor()
  
  var keyboardButtonFont: UIFont = UIFont(name: ButtonFontName, size: ButtonFontSize)!
  var buttonFontSize = 16
  var buttonSpecialFontSize = 12
  
  // #pragma mark - Configure Theme Data
  
  class func configureThemeData() -> [KeyboardThemeData] {
    let themeData = [KeyboardThemeData.solidTheme(),
      KeyboardThemeData.fadeTheme(),
      KeyboardThemeData.stripedTheme(),
      KeyboardThemeData.noneTheme()]
    
    return themeData
  }
  
  class func solidTheme() -> KeyboardThemeData {
    
    var theme: KeyboardThemeData = KeyboardThemeData()
    theme.themeID = 0
    theme.themeName = "Solid"
    
    theme.colorForBackground = UIColor(red: 107.0/255.0, green: 205.0/255.0, blue: 159.0/255.0, alpha: 1.0)
    
    theme.colorForCustomRow = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow1 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow2 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow3 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow4 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    
    theme.colorForButtonFont = UIColor.whiteColor()
    
    theme.keyboardButtonFont = UIFont(name: ButtonFontName, size: ButtonFontSize)!
    
    return theme
  }
  
  class func fadeTheme() -> KeyboardThemeData {
    
    var theme: KeyboardThemeData = KeyboardThemeData()
    theme.themeID = 1
    theme.themeName = "Fade"
    
    theme.colorForBackground = UIColor(red: 138.0/255, green: 212.0/255, blue: 177.0/255, alpha: 1.0)
    
    theme.colorForCustomRow = UIColor(red: 155.0/255, green: 217.0/255, blue: 187.0/255, alpha: 1.0)
    theme.colorForRow1 = UIColor(red: 138.0/255, green: 212.0/255, blue: 177.0/255, alpha: 1.0)
    theme.colorForRow2 = UIColor(red: 121.0/255, green: 208.0/255, blue: 166.0/255, alpha: 1.0)
    theme.colorForRow3 = UIColor(red: 103.0/255, green: 203.0/255, blue: 156.0/255, alpha: 1.0)
    theme.colorForRow4 = UIColor(red: 86.0/255, green: 198.0/255, blue: 146.0/255, alpha: 1.0)
    
    theme.colorForButtonFont = UIColor.whiteColor()
    
    theme.keyboardButtonFont = UIFont(name: ButtonFontName, size: ButtonFontSize)!
    
    return theme
  }
  
  class func stripedTheme() -> KeyboardThemeData {
    
    var theme: KeyboardThemeData = KeyboardThemeData()
    theme.themeID = 2
    theme.themeName = "Striped"
    
    theme.colorForBackground = UIColor(red: 122.0/255.0, green: 208.0/255, blue: 168.0/255, alpha: 1.0)
    
    theme.colorForCustomRow = UIColor(red: 103.0/255.0, green: 203.0/255, blue: 156.0/255, alpha: 1.0)
    theme.colorForRow1 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow2 = UIColor(red: 103.0/255.0, green: 203.0/255, blue: 156.0/255, alpha: 1.0)
    theme.colorForRow3 = UIColor(red: 69.0/255.0, green: 195.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    theme.colorForRow4 = UIColor(red: 103.0/255.0, green: 203.0/255, blue: 156.0/255, alpha: 1.0)
    
    theme.colorForButtonFont = UIColor.whiteColor()
    
    theme.keyboardButtonFont = UIFont(name: ButtonFontName, size: ButtonFontSize)!
    
    return theme
  }
  
  class func noneTheme() -> KeyboardThemeData {
    
    var theme: KeyboardThemeData = KeyboardThemeData()
    theme.themeID = 3
    theme.themeName = "None"
    
    theme.colorForBackground = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    
    theme.colorForCustomRow = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    theme.colorForRow1 = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    theme.colorForRow2 = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    theme.colorForRow3 = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    theme.colorForRow4 = UIColor(red: 239.0/255.0, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
    
    theme.colorForButtonFont = UIColor(red: 80.0/255.0, green: 203.0/255, blue: 154.0/255, alpha: 1.0)
    
    theme.keyboardButtonFont = UIFont(name: ButtonFontName, size: ButtonFontSize)!
    
    return theme
  }
}