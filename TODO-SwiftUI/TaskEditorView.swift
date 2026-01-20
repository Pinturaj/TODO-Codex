import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var itemToEdit: Item?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var priority: Item.Priority = .medium
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now
    @State private var completed: Bool = false

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    init(itemToEdit: Item? = nil) {
        self.itemToEdit = itemToEdit
        // State will be initialized in onAppear to ensure SwiftUI state is set after init
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if notes.isEmpty { Text("Notes").foregroundStyle(.secondary).padding(.top, 8) }
                            }, alignment: .topLeading
                        )
                }

                Section("Planning") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Item.Priority.allCases) { p in
                            Label(p.label, systemImage: p.systemImage).tag(p)
                        }
                    }
                    Toggle("Due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }
                }

                Section("Status") {
                    Toggle("Completed", isOn: $completed)
                }
            }
            .navigationTitle(itemToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadIfNeeded)
        }
        .gradientBackground()
    }

    private func loadIfNeeded() {
        guard let item = itemToEdit else { return }
        title = item.title
        notes = item.notes
        priority = item.priorityEnum
        if let dd = item.dueDate { hasDueDate = true; dueDate = dd }
        completed = item.completed
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let item = itemToEdit {
            item.title = trimmed
            item.notes = notes
            item.priorityEnum = priority
            item.dueDate = hasDueDate ? dueDate : nil
            item.completed = completed
        } else {
            let newItem = Item(title: trimmed,
                               notes: notes,
                               priority: priority.rawValue,
                               dueDate: hasDueDate ? dueDate : nil,
                               completed: completed,
                               timestamp: Date())
            modelContext.insert(newItem)
        }
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return TaskEditorView()
        .modelContainer(container)
}
