//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

struct TriviaResponseModel: Decodable {
    let questions: [TriviaQuestion]
}


struct TriviaQuestion: Decodable{
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        category = try container.decode(String.self, forKey: .category)
        question = try container.decode(String.self, forKey: .question)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
    }
}

class TriviaQuestionService {
    func fetchQuestions(category: String, difficulty: String, completion: @escaping ([TriviaQuestion]?) -> Void) {
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        components.queryItems = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "difficulty", value: difficulty)
        ]

        guard let url = components.url else {
            assertionFailure("Invalid URL")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                assertionFailure("Error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                assertionFailure("Invalid response status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                completion(nil)
                return
            }

            guard let data = data else {
                assertionFailure("Invalid data")
                completion(nil)
                return
            }

            let questions = self.parse(data: data)
            completion(questions)
        }

        task.resume()
    }

    private func parse(data: Data) -> [TriviaQuestion] {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(TriviaQuestion.self, from: data)
            return response.question
        } catch {
            assertionFailure("Error decoding JSON: \(error.localizedDescription)")
            return []
        }
    }
}

