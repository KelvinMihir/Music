//
//  Dynamic.swift
//  Dynamics
//
//  Created by James Bean on 4/27/16.
//
//

/// The performed loudness of a musical event.
///
// FIXME: Add effort dynamic flag
public struct Dynamic {

    // MARK: - Instance Properties

    /// A textual comment (e.g., "più", "forcefully", "gently", etc.)
    var annotation: String?

    /// A modifier for defining the `s` or `r` in `sforzando`, or `rinforzando`.
    var anteriorModifier: AnteriorModifier?

    /// A structure of the Dynamic.Element values contained herein.
    var elements: Elements

    /// A modifier for defining the `z` in `sforzando`, or `rinforzando`.
    var posteriorModifier: PosteriorModifier?

    // MARK: - Initializers

    /// Create a `Dynamic` with the given `annotation`, `anteriorModifier`, `elements`, and
    /// `posteriorModifier`.
    ///
    public init(
        annotation: String? = nil,
        anteriorModifier: AnteriorModifier? = nil,
        elements: Elements,
        posteriorModifier: PosteriorModifier? = nil
    )
    {
        self.annotation = annotation
        self.anteriorModifier = anteriorModifier
        self.elements = elements
        self.posteriorModifier = posteriorModifier
    }
}

extension Dynamic {

    static let rf = Dynamic.r(.f(1))
    static let rff = Dynamic.r(.f(2))
    static let rfff = Dynamic.r(.f(3))

    static let rfz = Dynamic.rf.z
    static let rffz = Dynamic.r(.f(2)).z
    static let rfffz = Dynamic.r(.f(3)).z

    static let sf = Dynamic.s(.f(1))
    static let sff = Dynamic.s(.f(2))
    static let sfff = Dynamic.s(.f(3))

    static let sfz = Dynamic.sf.z
    static let sffz = Dynamic.s(.f(2)).z
    static let sfffz = Dynamic.s(.f(3)).z

    static let sfp = Dynamic.s(.f,.p)
    static let sffp = Dynamic.s(.f(2),.p)
    static let sfffp = Dynamic.s(.f(3),.p)
    static let sfpp = Dynamic.s(.f,.p(2))
    static let sfppp = Dynamic.s(.f,.p(3))
    static let sffpp = Dynamic.s(.f(2),.p(2))
    static let sffppp = Dynamic.s(.f(2),.p(3))
    static let sfffpp = Dynamic.s(.f(3),.p(2))
    static let sfffppp = Dynamic.s(.f(3),.p(3))

    static let f = Dynamic(elements: .single(.f))
    static let ff = Dynamic(elements: .single(.f(2)))
    static let fff = Dynamic(elements: .single(.f(3)))
    static var ffff = Dynamic(elements: .single(.f(4)))
    static var fffff = Dynamic(elements: .single(.f(5)))
    static var ffffff = Dynamic(elements: .single(.f(6)))
    static var fffffff = Dynamic(elements: .single(.f(7)))
    static var ffffffff = Dynamic(elements: .single(.f(8)))

    static var p = Dynamic(elements: .single(.p))
    static var pp = Dynamic(elements: .single(.p(2)))
    static var ppp = Dynamic(elements: .single(.p(3)))
    static var pppp = Dynamic(elements: .single(.p(4)))
    static var ppppp = Dynamic(elements: .single(.p(5)))
    static var pppppp = Dynamic(elements: .single(.p(6)))
    static var ppppppp = Dynamic(elements: .single(.p(7)))
    static var pppppppp = Dynamic(elements: .single(.p(8)))

    static let fp = Dynamic(elements: .compound(.f,.p))
    static let mp = Dynamic(elements: .single(.mezzo(.p)))
    static let mf = Dynamic(elements: .single(.mezzo(.f)))

    /// - Returns: A `Dynamic` with the amount of forte elements, with the given `annotation`.
    static func f(_ count: Int, _ annotation: String? = nil) -> Dynamic {
        return .init(annotation: annotation, elements: .single(.f(count)))
    }

    /// - Returns: A `Dynamic` with the amount of piano elements, with the given `annotation`.
    static func p(_ count: Int, _ annotation: String? = nil) -> Dynamic {
        return .init(annotation: annotation, elements: .single(.p(count)))
    }

    /// - Returns: A `Dynamic` which prepends a `r` to the given `element`, with the given
    /// `annotation`.
    static func r(
        _ element: Element,
        _ annotation: String? = nil
    ) -> Dynamic
    {
        return .init(annotation: annotation, anteriorModifier: .r, elements: .single(element))
    }

    /// - Returns: A `Dynamic` with prepends an `s` to the given `element`, with the given
    /// `annotation`.
    static func s(
        _ element: Element,
        _ annotation: String? = nil
    ) -> Dynamic
    {
        return .init(annotation: annotation, anteriorModifier: .s, elements: .single(element))
    }

    /// - Returns: A `Dynamic` with the given `anterior` and `posterior` `Elements` joined together
    /// in a compound `Elements`, with the given `annotation`.
    static func s(
        _ anterior: Element,
        _ posterior: Element,
        _ annotation: String? = nil
    ) -> Dynamic {
        return .init(
            annotation: annotation,
            anteriorModifier: .s,
            elements: .compound(anterior, posterior)
        )
    }

    /// - Returns: A `Dynamic` with the same attributes as self, with an appended `z` for a
    /// rinforzando / sforzando.
    var z: Dynamic {
        precondition(posteriorModifier == nil, "You cannot make a zinger zing again!")
        return .init(
            annotation: annotation,
            anteriorModifier: anteriorModifier,
            elements: elements,
            posteriorModifier: .z
        )
    }
}

extension Dynamic {

    // MARK: - Numeric Representation

    /// - Returns: The numerical values of the anterior and posterior dynamic elements. If
    var numericValues: (anterior: Double, posterior: Double) {
        switch elements {
        case .single(let element):
            return (element.value, element.value)
        case .compound(let anterior, let posterior):
            return (anterior.value, posterior.value)
        }
    }
}

extension Dynamic {

    // MARK: - Associated Types

    /// Whether a `Dynamic` consistes a single element or a compound of two elements.
    public enum Elements {
        case single(Element)
        case compound(Element,Element)
    }

    /// A modifier for defining the `s` or `r` in `sforzando`, or `rinforzando`.
    public enum AnteriorModifier: String {

        // MARK: - Cases

        /// `r` for `rinforzando`
        case r

        /// `s` for `sforzando` or `subito`
        case s
    }

    /// A modifier for defining the `z` in `sforzando`, or `rinforzando`.
    public enum PosteriorModifier: String {

        /// MARK: - Cases

        /// The trailing `z` in a `rinforzando` or `sforzando`.
        case z
    }

    // FIXME: Add `.niente` case
    public enum Element {

        // MARK: - Type Properties

        /// Single piano dynamic element.
        static var p: Element {
            return .vector(.p, 1)
        }

        /// Single forte dynamic element.
        static var f: Element {
            return .vector(.f, 1)
        }

        // MARK: - Type Methods

        /// Piano vector dynamic element.
        static func p(_ count: Int = 1) -> Element {
            precondition(count >= 1)
            return vector(.p, count)
        }

        /// Forte vector dynamic element.
        static func f(_ count: Int = 1) -> Element {
            precondition(count >= 1)
            return vector(.f, count)
        }

        // MARK: - Associated Types

        /// The direction of a dynamic element.
        public enum Direction: Double {
            case p = -1
            case f = 1
        }

        // MARK: - Cases

        /// A mezzo forte or mezzo piano.
        case mezzo(Direction)

        /// A vector of a given `direction` with the given `magnitude`.
        case vector(_ direction: Direction, _ magnitude: Int)

        // MARK: - Instance Properties

        /// Numerical value of an `Element`.
        var value: Double {
            switch self {
            case .mezzo(let direction):
                return 0.5 * direction.rawValue
            case .vector(let direction, let magnitude):
                return direction.rawValue * Double(magnitude)
            }
        }
    }
}

extension Dynamic: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// Printable description of `Dynamic`.
    public var description: String {
        var result = ""
        if let anterior = anteriorModifier { result += anterior.rawValue }
        result += elements.description
        if let posterior = posteriorModifier { result += posterior.rawValue }
        if let annotation = annotation { result += ": " + annotation }
        return result
    }
}

extension Dynamic.Elements: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// Printable description of `Dynamic.Elements`.
    public var description: String {
        switch self {
        case .single(let element):
            return element.description
        case .compound(let a, let b):
            return a.description + b.description
        }
    }
}

extension Dynamic.Element: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// Printable description of `Dynamic.Element`.
    public var description: String {
        switch self {
        case .mezzo(let direction):
            return "m" + direction.description
        case .vector(let direction, let magnitude):
            return String(repeating: direction.description, count: magnitude)
        }
    }
}

extension Dynamic.Element.Direction: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// Printable description of `Dynamic.Element.Direction`.
    public var description: String {
        return self == .p ? "p" : "f"
    }
}
