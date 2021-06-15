
// todo: extension on string idk
extension String {

    /**
     gets matches & checks they are not equal to nil
     */
    func matches(_ regex: String) -> Bool {
        let matches = range(
            of: regex,
            options: .regularExpression,
            range: nil,
            locale: nil)
        return matches != nil
    }

    /**
     Replace regex matches
     replaceWith is the template (withTemplate)
     */
    func replacingRegexMatches(
        pattern: String,
        replaceWith: String = "") -> String {

        var newString = ""
        do {
            let regex = try NSRegularExpression(
                pattern: pattern,
                options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, count)
            newString = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: replaceWith)
        }
        catch {
            debugPrint("Error \(error)")
        }
        return newString
    }
}
