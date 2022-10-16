//
//  ToDoViewModel.swift
//  ToDoVapor
//
//  Created by Cédric Bahirwe on 17/10/2022.
//

import Foundation

final class ToDoViewModel: ObservableObject {
    @Published private(set) var todos: [TodoModel] = []

    public func createToDo() async {
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


    public func getToDos() async {
        let url = makeURL("todo-lists")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let result = try JSONDecoder().decode([TodoModel].self, from: data)

            self.todos = result
        } catch {
            print(error.localizedDescription)
        }
    }

    public func updateToDo(_ todo: TodoModel) async {
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
