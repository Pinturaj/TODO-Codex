//
//  ContentView.swift
//  TODO-SwiftUI
//
//  Created by Appsquadz on 19/01/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var auth: AuthStore

    enum SortOption: String, CaseIterable, Identifiable {
        case byDate = "Date Created"
        case byDueDate = "Due Date"
        case byPriority = "Priority"
        case alphabetical = "Alphabetical"
        var id: String { rawValue }

        var sortDescriptors: [SortDescriptor<Item>] {
            switch self {
            case .byDate:
                return [SortDescriptor(\.timestamp, order: .reverse)]
            case .byDueDate:
                return [SortDescriptor(\.dueDate, order: .forward), SortDescriptor(\.timestamp, order: .reverse)]
            case .byPriority:
                return [SortDescriptor(\.priority, order: .reverse), SortDescriptor(\.timestamp, order: .reverse)]
            case .alphabetical:
                return [SortDescriptor(\.title, order: .forward)]
            }
        }
    }

    private enum LoginIntent {
        case addTask
        case profile
        case none
    }

    @State private var sortOption: SortOption = .byDate
    @State private var showEditor: Bool = false
    @State private var itemToEdit: Item? = nil

    @State private var showLoginFullScreen: Bool = false
    @State private var navPath: [String] = []
    @State private var loginIntent: LoginIntent = .none

    var body: some View {
        ZStack {
            GradientBackground() // ensures gradient sits behind everything
            NavigationStack(path: $navPath) {
                ItemListView(sortDescriptors: sortOption.sortDescriptors, startEdit: startEdit, delete: delete)
                    .navigationTitle("My Tasks")
                    .toolbarTitleDisplayMode(.automatic)
                    .toolbarBackground(.clear, for: .navigationBar)
//                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Menu {
                                Picker("Sort by", selection: $sortOption) {
                                    ForEach(SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            } label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                Button {
                                    handleProfileTapped()
                                } label: {
                                    Image(systemName: "person.crop.circle")
                                }
                                Button {
                                    handleAddTaskTapped()
                                } label: {
                                    Label("Add Task", systemImage: "plus.circle.fill")
                                }
                                .keyboardShortcut(.init("n"), modifiers: [.command])
                            }
                        }
                    }
                    .sheet(isPresented: $showEditor) {
                        TaskEditorView(itemToEdit: itemToEdit)
                    }
                    .navigationDestination(for: String.self) { route in
                        switch route {
                        case "profile":
                            ProfileView(vm: ProfileViewModel(auth: auth))
                        default:
                            EmptyView()
                        }
                    }
                    .fullScreenCover(isPresented: $showLoginFullScreen) {
                        LoginView(vm: LoginViewModel(auth: auth) {
                            // on success: dismiss login and route based on intent
                            showLoginFullScreen = false
                            switch loginIntent {
                            case .addTask:
                                itemToEdit = nil
                                showEditor = true
                            case .profile:
                                navPath.append("profile")
                            case .none:
                                break
                            }
                            loginIntent = .none
                        })
                    }
            }
        }
    }

    private func handleProfileTapped() {
        if auth.isLoggedIn {
            navPath.append("profile")
        } else {
            loginIntent = .profile
            showLoginFullScreen = true
        }
    }

    private func handleAddTaskTapped() {
        if auth.isLoggedIn {
            itemToEdit = nil
            showEditor = true
        } else {
            loginIntent = .addTask
            showLoginFullScreen = true
        }
    }

    private func startEdit(_ item: Item) {
        itemToEdit = item
        showEditor = true
    }

    private func delete(_ item: Item) {
        withAnimation { modelContext.delete(item) }
    }
}

private struct ItemListView: View {
    var sortDescriptors: [SortDescriptor<Item>]
    var startEdit: (Item) -> Void
    var delete: (Item) -> Void

    @Query private var items: [Item]
    @Environment(\.modelContext) private var modelContext

    init(sortDescriptors: [SortDescriptor<Item>], startEdit: @escaping (Item) -> Void, delete: @escaping (Item) -> Void) {
        self.sortDescriptors = sortDescriptors
        self.startEdit = startEdit
        self.delete = delete
        _items = Query(sort: sortDescriptors)
    }

    var body: some View {
        if items.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "checklist")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No tasks yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                // The add button is managed by the parent toolbar/sheet
            }
            .padding()
        } else {
            List {
                ForEach(items) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Button {
                            withAnimation { item.completed.toggle() }
                        } label: {
                            Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.completed ? .green : .secondary)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.title)
                                    .strikethrough(item.completed)
                                    .foregroundStyle(item.completed ? .secondary : .primary)
                                    .font(.headline)
                                if let due = item.dueDate {
                                    Text(due, style: .date)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(.thinMaterial, in: .capsule)
                                }
                            }
                            if !item.notes.isEmpty {
                                Text(item.notes)
                                    .lineLimit(2)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            HStack(spacing: 8) {
                                Label(item.priorityEnum.label, systemImage: item.priorityEnum.systemImage)
                                    .font(.caption)
                                    .foregroundStyle(priorityColor(item.priorityEnum))
                                Spacer()
                                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { delete(item) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button { startEdit(item) } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .onTapGesture { startEdit(item) }
                }
                .onDelete { offsets in
                    withAnimation {
                        for index in offsets {
                            let item = items[index]
                            modelContext.delete(item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }

    private func priorityColor(_ p: Item.Priority) -> Color {
        switch p {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
