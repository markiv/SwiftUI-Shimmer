//
//  Placeholding.swift
//
//
//  Created by Vikram Kriplaney on 05.04.21.
//

import SwiftUI

/// Conforming types provide an instance of themselves to serve as placeholder.
public protocol Placeholding {
    static var placeholder: Self { get }
}

/// Extensions for `List`s with row selection support.
@available(watchOS, unavailable)
public extension List {
    /// A drop-in replacement `List` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: A collection of identifiable data for computing the list.
    ///   - selection: A binding to a set that identifies selected rows.
    ///   - placeholders: The number of placeholder items to display.
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    init<Data, RowContent>(
        _ data: Data,
        selection: Binding<Set<SelectionValue>>?,
        placeholders: Int,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
        Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
        Data.Element: Identifiable,
        Data.Element: Placeholding
    {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, selection: selection, rowContent: rowContent)
        } else {
            self.init(data, selection: selection, rowContent: rowContent)
        }
    }

    /// A drop-in replacement `List` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: A collection of identifiable data for computing the list.
    ///   - id: The key path to the data model’s identifier.
    ///   - selection: A binding to a set that identifies selected rows.
    ///   - placeholders: The number of placeholder items to display.
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        selection: Binding<Set<SelectionValue>>?,
        placeholders: Int,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Content == ForEach<Data, ID, HStack<RowContent>>,
        Data.Element: Placeholding,
        RowContent: View
    {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, id: id, selection: selection, rowContent: rowContent)
        } else {
            self.init(data, id: id, selection: selection, rowContent: rowContent)
        }
    }
}

public extension List where SelectionValue == Never {
    /// A drop-in replacement `List` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: A collection of identifiable data for computing the list.
    ///   - placeholders: The number of placeholder items to display.
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    init<Data, RowContent>(
        _ data: Data,
        placeholders: Int,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
        Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
        Data.Element: Identifiable,
        Data.Element: Placeholding
    {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, rowContent: rowContent)
        } else {
            self.init(data, rowContent: rowContent)
        }
    }

    /// A drop-in replacement `List` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: A collection of identifiable data for computing the list.
    ///   - id: The key path to the data model’s identifier.
    ///   - placeholders: The number of placeholder items to display.
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        placeholders: Int,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
        Content == ForEach<Data, ID, HStack<RowContent>>,
        Data.Element: Placeholding
    {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, id: id, rowContent: rowContent)
        } else {
            self.init(data, id: id, rowContent: rowContent)
        }
    }
}

public extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable,
    Data.Element: Placeholding
{
    /// A drop-in replacement `ForEach` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - placeholders: The number of placeholder items to display.
    ///   - content: The view builder that creates views dynamically.
    init(_ data: Data, placeholders: Int, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, content: content)
        } else {
            self.init(data, content: content)
        }
    }
}

public extension ForEach where Content: View, Data.Element: Placeholding {
    /// A drop-in replacement `ForEach` constructor that displays placeholders while the collection is empty.
    /// - Parameters:
    ///   - data: The data that the `ForEach` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - placeholders: The number of placeholder items to display.
    ///   - content: The view builder that creates views dynamically.
    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        placeholders: Int,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        if data.isEmpty, let placeholders = ((0 ..< placeholders).map { _ in Data.Element.placeholder }) as? Data {
            self.init(placeholders, id: id, content: content)
        } else {
            self.init(data, id: id, content: content)
        }
    }
}

#if DEBUG && os(iOS)
/// Example of a `List` that displays animated "skeletons" while loading data.
/// Start an iOS **Live Preview** to see it in action.
struct Placeholding_Previews: PreviewProvider {
    static var previews: some View {
        LocaleDemo()
    }

    /// A list item we can create from one of Foundation's built-in Locales.
    struct LocaleItem: Identifiable, Placeholding, View {
        let id: String
        let language: String
        let region: String?

        init(id: String, language: String, region: String?) {
            self.id = id
            self.language = language
            self.region = region
        }

        /// An example of a fixed placeholder.
        // public static var placeholder = Self(locale: .autoupdatingCurrent)

        /// An example with dynamic placeholders with random length strings.
        public static var placeholder: Self {
            Self(
                id: UUID().uuidString,
                language: String(repeating: "L", count: .random(in: 6...12)),
                region: String(repeating: "R", count: .random(in: 6...20))
            )
        }

        init(locale: Locale) {
            self.id = locale.identifier
            self.language = locale.languageCode
                .map { Locale.autoupdatingCurrent.localizedString(forLanguageCode: $0) ?? $0
                } ?? "?"
            self.region = locale.regionCode.map { Locale.autoupdatingCurrent.localizedString(forRegionCode: $0) ?? $0
            }
        }

        public var body: some View {
            Image(systemName: "bubble.left.fill").foregroundColor(.accentColor)
            Text(language)
            Spacer()
            if let region = region {
                Text(region)
                Image(systemName: "globe").foregroundColor(.secondary)
            }
        }
    }

    struct LocaleDemo: View {
        @State private var items: [LocaleItem] = []

        var body: some View {
            NavigationView {
                List(items, placeholders: 20) {
                    $0.shimmering(active: items.isEmpty, redact: true)
                }
                .listStyle(PlainListStyle())
                .onAppear(perform: fetchData)
                .navigationBarTitle(items.isEmpty ? "Loading..." : "Locales")
                .navigationBarItems(trailing:
                    Button(action: fetchData, label: {
                        Image(systemName: "arrow.clockwise")
                    }))
            }
        }

        /// Populates our collection, after pretending to do some work.
        func fetchData() {
            items = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                items = Locale.availableIdentifiers
                    .compactMap { Locale(identifier: $0) }
                    .map { LocaleItem(locale: $0) }
                    .shuffled()
            }
        }
    }
}
#endif
