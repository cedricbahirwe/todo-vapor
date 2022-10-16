//
//  ToDoViewModel.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 17/10/2022.
//

import Foundation

final class ToDoViewModel: ObservableObject {
    @Published var todos: [TodoModel] = []
    @Published private(set) var isLoading: Bool = false

    @MainActor
    public func createToDo(_ todo: TodoModel) async {
        var request = makeURLRequest("POST")
        isLoading = true
        do {
            request.httpBody = try JSONEncoder().encode(todo)
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
        isLoading = false
    }

    @MainActor
    public func getToDos() async {
        let url = makeURL("todo-lists")
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let result = try JSONDecoder().decode([TodoModel].self, from: data)

            self.todos = result
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }

    @MainActor
    public func updateToDo(_ todo: TodoModel) async {
        var request = makeURLRequest("PUT", path: todo.id.uuidString)

        isLoading = true
        do {
            request.httpBody = try JSONEncoder().encode(todo)
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
        isLoading = false
    }


    @MainActor
    func deleteToDo(_ todo: TodoModel) async {
        let request = makeURLRequest("DELETE", path: todo.id.uuidString)
        isLoading = true
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
        isLoading = false
    }

    var makeURl: (String) -> URL = {
        URL(string: "http://127.0.0.1:8080/\($0)")!
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
