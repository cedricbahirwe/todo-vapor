//
//  ContentView.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = ToDoViewModel()
    @FocusState private var isFocused: Bool
    @State private var editedTodo: TodoModel?

    var body: some View {
        NavigationView {
            List {
                if store.todos.isEmpty {
                    NewToDoField(onSubmit: { todo in
                        Task {
                            await store.createToDo(todo)
                        }
                    })
                }
                ForEach(store.todos) { todo in
                    if todo.id == editedTodo?.id {
                        TextField(
                            "Enter some notes",
                            text: Binding(get: {
                                return editedTodo?.name ?? ""
                            }, set: {
                                editedTodo?.name = $0
                            })
                        )
                        .lineLimit(1...5)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            Task {
                                guard let editedTodo else { return }
                                await store.updateToDo(editedTodo)
                                self.editedTodo = nil
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.accentColor)
                            Text(todo.name)
                        }
                        .onTapGesture {
                            editedTodo = todo
                            isFocused = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await store.deleteToDo(todo)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .overlay {
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .task {
                await store.getToDos()
            }
            .toolbar {
                Button {
                    Task {
                        let newTodo = TodoModel(name: "New to-do...")
                        await store.createToDo(newTodo)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .navigationBarTitle("ToDos")
        }
    }
}

extension ContentView {
    struct NewToDoField: View {
        @State private var todo = TodoModel(name: "")
        @FocusState private var isFocused: Bool
        var onSubmit: ((TodoModel) -> Void)
        var body: some View {
            TextField(
                "Type your first note",
                text: $todo.name
            )
            .focused($isFocused)
            .onSubmit {
                onSubmit(todo)
                isFocused = false
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
