//
// Created by obeta on 2022/3/20.
//

import Foundation

let swiftLanguage: [String: LanguageDefinition] = [
    "identifier": LanguageDefinition(
        regex: "(\\.[A-Za-z_]+\\w*)|((NS|UI)[A-Z][a-zA-Z]+)|((println|print)(?=\\())|(Any|Array|AutoreleasingUnsafePointer|BidirectionalReverseView|Bit|Bool|CFunctionPointer|COpaquePointer|CVaListPointer|Character|CollectionOfOne|ConstUnsafePointer|ContiguousArray|Data|Dictionary|DictionaryGenerator|DictionaryIndex|Double|EmptyCollection|EmptyGenerator|EnumerateGenerator|FilterCollectionView|FilterCollectionViewIndex|FilterGenerator|FilterSequenceView|Float|Float80|FloatingPointClassification|GeneratorOf|GeneratorOfOne|GeneratorSequence|HeapBuffer|HeapBuffer|HeapBufferStorage|HeapBufferStorageBase|ImplicitlyUnwrappedOptional|IndexingGenerator|Int|Int16|Int32|Int64|Int8|IntEncoder|LazyBidirectionalCollection|LazyForwardCollection|LazyRandomAccessCollection|LazySequence|Less|MapCollectionView|MapSequenceGenerator|MapSequenceView|MirrorDisposition|ObjectIdentifier|OnHeap|Optional|PermutationGenerator|QuickLookObject|RandomAccessReverseView|Range|RangeGenerator|RawByte|Repeat|ReverseBidirectionalIndex|Printable|ReverseRandomAccessIndex|SequenceOf|SinkOf|Slice|StaticString|StrideThrough|StrideThroughGenerator|StrideTo|StrideToGenerator|String|Index|UTF8View|Index|UnicodeScalarView|IndexType|GeneratorType|UTF16View|UInt|UInt16|UInt32|UInt64|UInt8|UTF16|UTF32|UTF8|UnicodeDecodingResult|UnicodeScalar|Unmanaged|UnsafeArray|UnsafeArrayGenerator|UnsafeMutableArray|UnsafePointer|VaListBuilder|Header|Zip2|ZipGenerator2)",
        group: 0,
        relevance: 1,
        options: [],
        multiline: false
    ),
    "keyword": LanguageDefinition(
        regex: "\\b(as|associatedtype|break|case|catch|class|continue|convenience|default|defer|deinit|else|enum|extension|fallthrough|false|fileprivate|final|for|func|get|guard|if|import|in|init|inout|internal|is|lazy|let|mutating|nil|nonmutating|open|operator|override|private|protocol|public|repeat|required|rethrows|return|required|self|set|some|static|struct|subscript|super|switch|throw|throws|true|try|typealias|unowned|var|weak|where|while)\\b",
        group: 0,
        relevance: 1,
        options: [],
        multiline: false
    ),
    "numbers": LanguageDefinition(
        regex: "(?<=(\\s|\\[|,|:))([-]*\\d|\\.|_)+",
        group: 0,
        relevance: 0,
        options: [],
        multiline: false
    ),
    "string": LanguageDefinition(
        regex: #"(?<!\\)".*?(?<!\\)""#,
        group: 0,
        relevance: 3,
        options: [],
        multiline: false
    ),
    "mult_string": LanguageDefinition(
        regex: "\"\"\"(.*?)\"\"\"",
        group: 0,
        relevance: 4,
        options: [NSRegularExpression.Options.dotMatchesLineSeparators],
        multiline: true
    ),
    "comment": LanguageDefinition(
        regex: "(?<!:)\\/\\/.*?(\n|$)",
        group: 0,
        relevance: 5,
        options: [],
        multiline: false
    ),
    "multi_comment": LanguageDefinition(
        regex: "/\\*.*?\\*/",
        group: 0,
        relevance: 5,
        options: [NSRegularExpression.Options.dotMatchesLineSeparators],
        multiline: true
    ),
]
