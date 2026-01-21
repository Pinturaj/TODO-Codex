//
//  TODO_SwiftUIApp.swift
//  TODO-SwiftUI
//
//  Created by Appsquadz on 19/01/26.
//

import SwiftUI
import SwiftData
import Combine

@main
struct TODO_SwiftUIApp: App {
    @StateObject private var authStoreHolder = AuthStoreHolder()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Session.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authStoreHolder.authStore)
                .onAppear {
                    // Ensure auth store has model context after container is attached
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: sharedModelContainer) { _, _ in
            // no-op; container is constant in this app
        }
    }
}

@MainActor
private final class AuthStoreHolder: ObservableObject {
    let apiHandler: APIHandler
    let authStore: AuthStore

    init() {
        // Initialize API without a model context; we'll inject it later.
        self.apiHandler = APIHandler(modelContext: nil)

        // Create a temporary in-memory ModelContainer/ModelContext
        // so AuthStore can be constructed before the real context is available.
        let tempSchema = Schema([
            Item.self,
            Session.self,
        ])
        let tempConfig = ModelConfiguration(schema: tempSchema, isStoredInMemoryOnly: true)
        let tempContainer = try! ModelContainer(for: tempSchema, configurations: [tempConfig])
        let tempContext = ModelContext(tempContainer)

        // Initialize AuthStore with the temporary context; it will be replaced on RootView appear.
        self.authStore = AuthStore(modelContext: tempContext, api: apiHandler)
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        ContentView()
            .environmentObject(auth)
            .onAppear {
                // Re-wire model context into stores once available
                auth.setModelContext(modelContext)
            }
            .globalGradientBackground()
    }
}
