//
//  CloudKitManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/15/25.
//

import CloudKit

// A simple struct to hold the score data
struct HighScore {
    let playerName: String
    let score: Int
}

class CloudKitManager {
    
    static let shared = CloudKitManager()
    //private lazy var publicDB = CKContainer.default().publicCloudDatabase
    private let publicDB = CKContainer(identifier: "iCloud.RockMagic").publicCloudDatabase
    private init() {}
    
    /// Saves a new high score to the public database.
    func saveHighScore(playerName: String, score: Int, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "HighScores")
        record["playerName"] = playerName as CKRecordValue
        record["score"] = score as CKRecordValue
        
        publicDB.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetches the top 10 high scores from the public database.
    func fetchHighScores(completion: @escaping ([HighScore]?, Error?) -> Void) {
        let predicate = NSPredicate(value: true) // Get all records
        let query = CKQuery(recordType: "HighScores", predicate: predicate)
        
        // Sort by score in descending order
        query.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            var highScores: [HighScore] = []
            if let records = records {
                for record in records {
                    if let name = record["playerName"] as? String, let score = record["score"] as? Int {
                        highScores.append(HighScore(playerName: name, score: score))
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(highScores, nil)
            }
        }
    }
}
