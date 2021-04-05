//
//  File.swift
//
//
//  Created by Vikram Kriplaney on 05.04.21.
//

import SwiftUI

public protocol Skeletal {
    static var skeleton: Self { get }
}

public extension List {
    init<Data, RowContent>(
        _ data: Data, skeletons: Int,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
        Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>,
        Data: RandomAccessCollection,
        RowContent: View,
        Data.Element: Identifiable,
        Data.Element: Skeletal,
        SelectionValue == Never
    {
        if
            data.isEmpty,
            let skeletons = ((0 ..< skeletons).map { _ in Data.Element.skeleton }) as? Data
        {
            self.init(skeletons, rowContent: rowContent)
        } else {
            self.init(data, rowContent: rowContent)
        }
    }
}

@available(iOS 14.0, *)
struct Skeletons_LibraryContent: LibraryContentProvider {
    var views: [LibraryItem] {
        LibraryItem(Shimmer(), title: "Shimmer this view", category: .effect, matchingSignature: "shi")
    }
}

#if DEBUG

struct User: Identifiable, Skeletal {
    let id = UUID()
    let username: String
    let firstName: String
    let lastName: String

    static var skeleton: Self {
        Self(username: "username", firstName: "Firstname", lastName: "Lastname")
//        Self(
//            username: String(repeating: "x", count: .random(in: 10...25)),
//            firstName: String(repeating: "F", count: .random(in: 3...10)),
//            lastName: String(repeating: "L", count: .random(in: 4...12))
//        )
    }

    static let sample: [Self] = [
        User(username: "ringo", firstName: "Ringo", lastName: "Starr"),
        User(username: "john", firstName: "John", lastName: "Lennon"),
        User(username: "paul", firstName: "Paul", lastName: "McCartney"),
        User(username: "george", firstName: "George", lastName: "Harrison"),
        User(username: "markiv", firstName: "Vikram", lastName: "Kriplaney")
    ]
}

@available(iOS 14.0, *)
struct Skeletons_Previews: PreviewProvider {
    struct Demo: View {
        @State private var users: [User] = []

        var body: some View {
            NavigationView {
                List(users, skeletons: 10) { user in
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(user.firstName)
                            Text(user.lastName).bold()
                        }
                        Text(user.username).foregroundColor(.secondary)
                    }
                    .shimmering(active: users.isEmpty, redact: true)
                }
                .navigationBarTitle("Users")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        users = User.sample.shuffled()
                    }
                }
            }
        }
    }

    static var previews: some View {
        Demo()
    }
}
#endif
