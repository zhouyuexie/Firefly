//
//  SyntaxAttributedString.swift
//  Firefly
//
//  Created by Zachary lineman on 12/24/20.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// The state of a placeholder
public enum EditorPlaceholderState {
    case active
    case inactive
}

public extension NSAttributedString.Key {
    /// An NSAttributedString Key that is used for placeholders
    static let editorPlaceholder = NSAttributedString.Key("editorPlaceholder")
}

open class SyntaxAttributedString : NSTextStorage {
    /// Internal Storage
    var stringStorage = NSTextStorage()
    
    /// Cached tokens
    var cachedTokens: [Token] = []
    
    /// Returns a standard String based on the current one.
    open override var string: String { get { return stringStorage.string } }
    
    /// The Syntax that is used for highlighting
    var syntax: Syntax
    
    /// The current range we are editing
    var editingRange: NSRange = NSRange(location: 0, length: 0)
    
    /// The last length of a token
    var lastLength: Int = 0
    
    /// The max length of a token
    var maxTokenLength: Int = 300000
    
    /// Whether or not placeholders are allowed to be generated
    var placeholdersAllowed: Bool = false
    
    /// Whether or not placeholders should have a link embedded
    var linkPlaceholders: Bool = false
    
    /// Init the Text Storage with a given syntax
    /// - Parameter syntax: The syntax to highlight text with
    public init(syntax: Syntax) {
        self.syntax = syntax
        super.init()
    }
    
    /// Initialize the SyntaxAttributedString
    public override init() {
        self.syntax = Syntax(language: .basic, theme: "basic", font: "system")
        super.init()
    }
    
    /// Initialize the SyntaxAttributedString
    required public init?(coder: NSCoder) {
        self.syntax = Syntax(language: .basic, theme: "basic", font: "system")
        super.init(coder: coder)
    }
    
    #if canImport(AppKit)
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    #endif
    
    /// Called internally every time the string is modified.
    open override func processEditing() {
        super.processEditing()
//        if self.editedMask.contains(.editedCharacters) {
//                        let string = (self.string as NSString)
//                        let range: NSRange = string.paragraphRange(for: editedRange)
//
//                        highlight(range)
//        }
    }
    
    /// Required function
    open override func beginEditing() {
        super.beginEditing()
    }
    
    /// Required function
    open override func endEditing() {
        super.endEditing()
    }
    
    /**
     Replaces the characters at the given range with the provided string.
     
     - parameter range: NSRange
     - parameter str:   String
     */
    open override func replaceCharacters(in range: NSRange, with str: String) {
        stringStorage.replaceCharacters(in: range, with: str)
        self.edited(TextStorageEditActions.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    /**
     Returns the attributes for the character at a given index.
     
     - parameter location: Int
     - parameter range:    NSRangePointer
     
     - returns: Attributes
     */
    open override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [AttributedStringKey : Any] {
        return stringStorage.attributes(at: location, effectiveRange: range)
    }
    
    /**
     Sets the attributes for the characters in the specified range to the given attributes.
     
     - parameter attrs: [String : AnyObject]
     - parameter range: NSRange
     */
    open override func setAttributes(_ attrs: [AttributedStringKey : Any]?, range: NSRange) {
        //        Dispatch.main {
        self.stringStorage.setAttributes(attrs, range: range)
        self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
        //        }
    }
    
    /// Adds attributes to a certain range of text
    /// - Parameters:
    ///   - attrs: Attributes to add
    ///   - range: Range of text to alter
    open override func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
        //        Dispatch.main {
        self.stringStorage.addAttributes(attrs, range: range)
        self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
        //        }
    }
    
    /// Adds attributes to a certain range of text
    /// - Parameters:
    ///   - name: Attribute to remove
    ///   - range: Range of text to remove attribute from
    open override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        //        Dispatch.main {
        self.stringStorage.removeAttribute(name, range: range)
        self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
        //        }
    }
}

//MARK: Highlighting
extension SyntaxAttributedString {
    
    /// Highlights a given range of text
    /// - Parameters:
    ///   - range: The range of text to highlight
    ///   - cursorRange: The current range of the cursor
    ///   - secondPass: If this is the second pass of highlighting
    func highlight(_ range: NSRange, cursorRange: NSRange?, secondPass: Bool = false) {
        self.beginEditing()

        #if DEBUG
        let start = DispatchTime.now()
        #endif
        var cursorRange = cursorRange
        if cursorRange == nil {
            cursorRange = range
        }
        let range = changeCurrentRange(currRange: range, cursorRange: cursorRange!)
        
        if !(range.location + range.length > string.utf16.count) {
            self.setAttributes([NSAttributedString.Key.foregroundColor: syntax.theme.defaultFontColor, NSAttributedString.Key.font: syntax.currentFont], range: range)
            self.removeAttribute(.editorPlaceholder, range: range)
            
            for item in syntax.definitions {
                var regex = try? NSRegularExpression(pattern: item.regex)
                if let option = item.matches.first {
                    regex = try? NSRegularExpression(pattern: item.regex, options: option)
                }
                
                regex?.enumerateMatches(in: string, options: .reportProgress, range: range, using: { (result, flags, stop) in
                    if let result = result {
                        if item.type == "placeholder" && placeholdersAllowed {
                            let textRange: NSRange = result.range(at: 2)
                            let startRange: NSRange = result.range(at: 1)
                            let endRange: NSRange = result.range(at: 3)
                            
                            self.addAttributes([.foregroundColor: FireflyColor.clear, .font: FireflyFont.systemFont(ofSize: 0.01)], range: startRange)
                            self.addAttributes([.foregroundColor: FireflyColor.clear, .font: FireflyFont.systemFont(ofSize: 0.01)], range: endRange)
                        
                            self.addAttributes([.editorPlaceholder: EditorPlaceholderState.inactive, .font: syntax.currentFont, .foregroundColor: syntax.theme.defaultFontColor,.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: syntax.theme.selection], range: textRange)
                            if linkPlaceholders {
                                if let strRange = Range(textRange, in: string) {
                                    let str = String(string[strRange]).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                                    self.addAttributes([.link: str], range: textRange)
                                }
                            }
                            addToken(range: result.range, type: item.type, multiline: item.multiLine)
                        } else {
                            let textRange: NSRange = result.range(at: item.group)
                            let color = syntax.getHighlightColor(for: item.type)
                            addToken(range: textRange, type: item.type, multiline: item.multiLine)
                            self.addAttributes([.foregroundColor: color, .font: syntax.currentFont], range: textRange)
                        }
                    }
                })
            }

            #if DEBUG
            let end = DispatchTime.now()
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            debugPrint("Highlighting range: \(range) took \(timeInterval)")
            #endif
        } else {
            debugPrint("Outside the String Length")
            print(range.location + range.length, string.utf16.count)
        }
        self.endEditing()
    }
    
    /// Check to see if we are inside a placeholder
    /// - Parameter cursorRange: The range of the cursor
    /// - Returns: Returns if we are inside a placeholder or not & the token of the current placeholder
    func insidePlaceholder(cursorRange: NSRange) -> (Bool, Token?) {
        let tokens = cachedTokens.filter { (token) -> Bool in return token.range.encompasses(r2: cursorRange) && token.type == "placeholder" }
        return (!tokens.isEmpty, tokens.first)
    }
    
    
    /// Creates and then adds a token to the cached tokens
    /// - Parameters:
    ///   - range: The range of the token
    ///   - type: The type of the token
    ///   - multiline: If the token is multiline or not
    func addToken(range: NSRange, type: String, multiline: Bool) {
        cachedTokens.append(Token(range: range, type: type, isMultiline: multiline))
    }
    
    
    /// Alters the current range depending on if we need to highlight a multiline string, or a token that goes slightly out of view
    /// - Parameters:
    ///   - currRange: The current range we want to highlight
    ///   - cursorRange: The range of the cursor
    /// - Returns: The altered range
    func changeCurrentRange(currRange: NSRange, cursorRange: NSRange) -> NSRange {
        var range: NSRange = currRange
        let tokens = cachedTokens.filter { (token) -> Bool in return token.isMultiline }.filter { (token) -> Bool in return token.range.touches(r2: currRange) }
        let lengthDifference = string.count - lastLength
        
        for token in tokens {
            // When typing a character directly before a multi-line token the system will recognize it as part of the current token. This is because the lowerbound is the same as the upper bound of the newly placed character
            if token.range.touches(r2: range) {
                if token.range.length <= maxTokenLength {
                    //Upper and lower bounds
                    let tokenLower = token.range.lowerBound
                    let tokenUpper = token.range.upperBound
                    let rangeLower = range.lowerBound
                    let rangeUpper = range.upperBound
                    
                    let multLocation: Int = token.range.location
                    
                    let origLocation: Int = range.location
                    let origLength: Int = range.length
                    
                    var newLocation: Int = range.location
                    var newLength: Int = range.length
                    
                    if (tokenLower < rangeLower) && (tokenUpper > rangeUpper) {
                        debugPrint("Lower & Upper off screen")
                        let locationDifference = origLocation - multLocation
                        let leDifference = lengthDifference + (tokenUpper - rangeUpper)
                        newLength = (origLength + locationDifference + leDifference)
                        newLocation = multLocation
                    } else if tokenLower < rangeLower {
                        debugPrint("Lower end off screen")
                        let locationDifference = origLocation - multLocation
                        newLength = origLength + locationDifference
                        newLocation = multLocation
                    } else if tokenUpper > rangeUpper {
                        debugPrint("Upper end off screen")
                        newLength = tokenUpper + lengthDifference
                    }
                    
                    if newLength + newLocation > string.utf16.count {
                        debugPrint("Is Greater")
                        newLength = string.utf16.count - newLocation
                    }
                    
                    let newRange = NSRange(location: newLocation, length: newLength)
                    range = newRange
                } else {
                    debugPrint("Token over max length")
                }
            }
        }
        
        lastLength = string.count
        invalidateTokens(in: range)
        
        return range
    }
    
/// This is not needed anymore & and i don't remember what it was used for exactly.
//    func adjustBelowRange(_ token: inout Token, _ tokenLower: inout Int, _ tokenUpper: inout Int, _ cursorLower: inout Int, _ cursorRange: NSRange, _ cursorUpper: inout Int, _ origLocation: Int, _ newLength: inout Int) {
//        if let index = cachedTokens.firstIndex(of: token) {
//            if lastLength < string.count {
//                let difference = string.count - lastLength
//                cachedTokens[index].range = NSRange(location: token.range.location + difference, length: token.range.length)
//                token.range = NSRange(location: token.range.location + difference, length: token.range.length)
//            } else if lastLength > string.count {
//                let difference = lastLength - string.count
//                cachedTokens[index].range = NSRange(location: token.range.location - difference, length: token.range.length)
//                token.range = NSRange(location: token.range.location - difference, length: token.range.length)
//            }
//            tokenLower = token.range.lowerBound
//            tokenUpper = token.range.upperBound
//            cursorLower = cursorRange.lowerBound
//            cursorUpper = cursorRange.upperBound
//        }
//        let spaceBetweenCursorAndToken: Int = tokenLower - cursorUpper
//        let startToCursorEnd: Int = cursorUpper - origLocation
//        newLength = startToCursorEnd + spaceBetweenCursorAndToken
//    }
    
    /// Check to see if we are editing in a multiline token
    /// - Returns: Bool indicating if we are editing in a multiline token & that multiline token
    func isEditingInMultiline() -> (Bool, Token?) {
        let tokens = getMultilineTokens(in: editingRange)
        let firstToken: Token? = tokens.first
        return (!tokens.isEmpty, firstToken)
    }
    
    /// Retrieves all the multiline tokens in the given range
    /// - Parameter range: The range to search in
    /// - Returns: An array of tokens that are multiline and in the given seach range
    func getMultilineTokens(in range: NSRange) -> [Token] {
        let multilineTokens = cachedTokens.filter { (token) -> Bool in
            return range.overlaps(range: token.range) && token.isMultiline
        }
        return multilineTokens
    }
    
    /// Removes all the tokens in the given range
    /// - Parameter range: The range that we should remove tokens from
    func invalidateTokens(in range: NSRange) {
        cachedTokens.removeAll { (token) -> Bool in
            return range.touches(r2: token.range)
        }
    }
    
    /// Reset's the view
    func resetView() {
        cachedTokens.removeAll()
        self.setAttributes([NSAttributedString.Key.foregroundColor: syntax.theme.defaultFontColor, NSAttributedString.Key.font: syntax.currentFont], range: NSRange(location: 0, length: string.count))
    }
}
