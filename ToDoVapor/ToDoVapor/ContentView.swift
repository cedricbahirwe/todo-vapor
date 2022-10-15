//
//  ContentView.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 15/10/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoModel] = []

    var body: some View {
        NavigationView {
            VStack {

                List {
                    if todos.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }

                    ForEach(todos) { todo in
                        Text(todo.name)
                            .onTapGesture {
                                Task {
                                    await updateToDo(todo)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await deleteToDo(todo)
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
                        await postToDo()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .task {
                await getToDos()
            }
            .navigationBarTitle("ToDos")
        }
    }

    func deleteToDo(_ todo: TodoModel) async {
        let request = makeURLRequest("DELETE", path: todo.id.uuidString)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 204 {
                await getToDos()
            } else {
                print(data, response)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func postToDo() async {
        var request = makeURLRequest("POST")

        do {
            let model = TodoModel(name: UUID().description)
            request.httpBody = try JSONEncoder().encode(model)
        } catch {
            print("The error \(error.localizedDescription)")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                await getToDos()
            } else {
                print(data, response)
            }
        } catch {
            print(error.localizedDescription)
        }
    }


    func getToDos() async {
        let url = makeURL("todo-lists")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let result = try JSONDecoder().decode([TodoModel].self, from: data)

            self.todos = result
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateToDo(_ todo: TodoModel) async {
        var request = makeURLRequest("PUT", path: todo.id.uuidString)

        do {
            let model = TodoModel(id: todo.id, name: UUID().description)
            request.httpBody = try JSONEncoder().encode(model)
        } catch {
            print("The error \(error.localizedDescription)")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                await getToDos()
            } else {
                print(data, response)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func makeURL(_ endpoint: String) -> URL {
        URL(string: "http://127.0.0.1:8080/\(endpoint)")!
    }

    private func makeURLRequest(_ method: String, path: String = "") -> URLRequest {
        let url = makeURL("todo-lists/\(path)")

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
