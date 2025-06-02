import Foundation

public struct SessionLocationStringSpecifier {
    public let remote: String
    public let remotePlural: String
    public let local: String

    public init(
        remote: String = "huisbezoek",
        remotePlural: String = "huisbezoeken",
        local: String = "in Alkmaar",
    ) {
        self.remote = remote
        self.remotePlural = remotePlural
        self.local = local
    }
}

public enum SessionLocation {
    case local
    case remote
}

public struct SessionLocationString {
    public let total: Int
    public let local: Int
    public let strings: SessionLocationStringSpecifier

    public var remote: Int { return total - local }

    public init(
        total: Int,
        local: Int,
        strings: SessionLocationStringSpecifier = SessionLocationStringSpecifier()
    ) {
        self.total = total
        self.local = local
        self.strings = strings
    }

    public init(
        estimationObject: SessionCountEstimationObject,
        strings: SessionLocationStringSpecifier = SessionLocationStringSpecifier()
    ) {
        self.total = estimationObject.count
        self.local = estimationObject.local
        self.strings = strings
    }


    public func split(for location: SessionLocation) -> String {
        let includeNumber = total > 1 ? true : false

        var output = ""
        
        switch location {
            case .remote:
            switch remote {
                case 0:
                    break
                case 1:
                    output.append((includeNumber ? "1 " : ""))
                    output.append(strings.remote)
                default:
                    output.append("\(remote) ")
                    output.append(strings.remotePlural)
            }

            case .local:
            switch local {
                case 0:
                    break
                case 1:
                    output.append((includeNumber ? "1 " : ""))
                    output.append(strings.local)
                default:
                    output.append("\(local) ")
                    output.append(strings.local)
            }
        }
        return output
    }

    public func combined() -> String {
        let includeNumber = total > 1 ? true : false
        let includeComma = (remote > 0) ? true : false

        var output = ""

        switch remote {
            case 0:
                break
            case 1:
                output.append((includeNumber ? "1 " : ""))
                output.append(strings.remote)
            default:
                output.append("\(remote) ")
                output.append(strings.remotePlural)
        }

        switch local {
            case 0:
                break
            case 1:
                if includeComma {
                    output.append(", ")
                }
                output.append((includeNumber ? "1 " : ""))
                output.append(strings.local)
            default:
                if includeComma {
                    output.append(", ")
                }
                output.append("\(local) ")
                output.append(strings.local)
        }
        return output
    }
}
