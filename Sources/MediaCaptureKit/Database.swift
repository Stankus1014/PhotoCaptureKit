//
//  Database.swift
//  MediaCaptureKit
//
//  Created by William Stankus on 9/26/25.
//
import Foundation
import SQLite

actor Database {
    
    static let shared = Database()
    
    typealias Expression = SQLite.Expression
    
    var database: Connection?
    
    private let photoManifestTable = Table("photos_table")
    private let photoID = Expression<Int>("photo_id")
    private let photoFileName = Expression<String>("photo_file_name")
    private let photoDate = Expression<Date>("photo_date")
    
    private init() {}
    
    func bootUp() {
        createConnection()
    }
    
    private func createConnection() {
        do {
            let dbPath = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("media_capture_kit.sqlite3")
                .path

            database = try Connection(dbPath)
            guard let database = database else { return }

            createPhotosTable()
        } catch {
            print("! -- Error Creating Photos Database -- !")
        }
    }
    
    private func createPhotosTable() {
        guard let database = database else { return }
        
        do {
            try database.run(self.photoManifestTable.create(ifNotExists: true) { table in
                table.column(self.photoID, primaryKey: .autoincrement)
                table.column(self.photoFileName)
                table.column(self.photoDate)
            })
        } catch {
            print("! -- Error Creating Photos Table -- !")
        }
    }
    
    func addPhoto(fileName: String) {
        guard let database = database else { return }
        
        do {
            let insert = photoManifestTable.insert(
                self.photoFileName <- fileName,
                self.photoDate <- Date()
            )
            try database.run(insert)
        } catch {
            print("! -- Error Adding Image -- !")
        }
    }
    
    func fetchPhotos(date: Date) -> [PhotoMetadata]? {
        guard let database = database else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        do {
            let query = photoManifestTable
                .filter(self.photoDate >= startOfDay && self.photoDate <= nextDay)
                .order(photoDate.desc)
            
            let rows = try database.prepare(query)
            
            var results: [PhotoMetadata] = []
            for row in rows {
                let fileName = row[self.photoFileName]
                let date = row[self.photoDate]
                results.append(PhotoMetadata(fileName: fileName, date: date))
            }
            return results
        } catch {
            print("! -- Error fetching photo metadata for date: \(date)")
            return []
        }
    }
    
    func fetchPhotos(startDate: Date, endDate: Date) -> [PhotoMetadata]? {
        guard let database = database else { return [] }
        
        let calendar = Calendar.current
        let startRange = calendar.startOfDay(for: startDate)
        
        let startOfEndDate = calendar.startOfDay(for: endDate)
        guard let endRange = calendar.date(byAdding: .day, value: 1, to: startOfEndDate) else { return nil }
        
        do {
            let query = self.photoManifestTable
                .filter(self.photoDate >= startRange && self.photoDate <= endRange)
                .order(self.photoDate.desc)
            
            let rows = try database.prepare(query)
            
            var results: [PhotoMetadata] = []
            for row in rows {
                let fileName = row[self.photoFileName]
                let date = row[self.photoDate]
                results.append(PhotoMetadata(fileName: fileName, date: date))
            }
            return results
        } catch {
            print("! -- Error fetching photo metadata for start date: \(startDate) to end date: \(endDate)")
            return []
        }
    }
    
    func fetchAllPhotos() -> [PhotoMetadata]? {
        guard let database = database else { return [] }
        
        do {
            let query = self.photoManifestTable
                .order(self.photoDate.desc)
            
            let rows = try database.prepare(query)
            
            var results: [PhotoMetadata] = []
            for row in rows {
                let fileName = row[self.photoFileName]
                let date = row[self.photoDate]
                results.append(PhotoMetadata(fileName: fileName, date: date))
            }
            return results
        } catch {
            print("! -- Error fetching all photo metadata")
            return []
        }
    }
    
    func deletePhoto(fileName: String) {
        guard let database = database else { return }
        
        do {
            let photo = self.photoManifestTable.filter(self.photoFileName == fileName)
            try database.run(photo.delete())
        } catch {
            print("! -- Error Deleting Photo for FileName: \(fileName)")
        }
    }
    
    func deletePhotos(date: Date) {
        guard let database = database else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        do {
            let photos = self.photoManifestTable.filter(self.photoDate >= startOfDay && self.photoDate <= nextDay)
            try database.run(photos.delete())
        } catch {
            print("! -- Error Deleting Photo for Date: \(date)")
        }
    }
    
    func deletePhotos(startDate: Date, endDate: Date) {
        guard let database = database else { return }
        
        let calendar = Calendar.current
        let startRange = calendar.startOfDay(for: startDate)
        
        let startOfEndDate = calendar.startOfDay(for: endDate)
        guard let endRange = calendar.date(byAdding: .day, value: 1, to: startOfEndDate) else { return }
        
        do {
            let photos = self.photoManifestTable.filter(self.photoDate >= startRange && self.photoDate <= endRange)
            try database.run(photos.delete())
        } catch {
            print("! -- Error Deleting Photo between: \(startDate) & \(endDate)")
        }
    }
    
    func deleteAllPhotos() {
        guard let database = database else { return }
        
        do {
            try database.run(self.photoManifestTable.delete())
        } catch {
            print("! -- Error Deleting All Photos")
        }
    }
    
    // TODO: Smart Delete
    
}

public struct PhotoMetadata: Sendable {
    let fileName: String
    let date: Date
}
