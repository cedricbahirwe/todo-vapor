//
//  ContentView.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = ToDoViewModel()

    var body: some View {
        NavigationView {
            VStack {

                List {
                    if store.todos.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }

                    ForEach(store.todos) { todo in
                        Text(todo.name)
                            .onTapGesture {
                                Task {
                                    await store.updateToDo(todo)
                                }
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
            .toolbar {
                Button {
                    Task {
                        await store.createToDo()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .task {
                await store.getToDos()
            }
            .navigationBarTitle("ToDos")
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
