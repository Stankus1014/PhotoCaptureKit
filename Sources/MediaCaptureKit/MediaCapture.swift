//
//  API.swift
//  MediaCaptureKit
//
//  Created by William Stankus on 9/26/25.
//
import Foundation

public class MediaCapture {
    
    public static func addPhoto(photoData: Data) async {
        await Database.shared.bootUp()
        let uuid = UUID()
        PhotoFileManager.persistFile(imageData: photoData, uuidString: uuid.uuidString)
        await Database.shared.addPhoto(fileName: uuid.uuidString)
    }
    
    public static func fetchPhotoMetadata(date: Date) async -> [PhotoMetadata]? {
        await Database.shared.bootUp()
        return await Database.shared.fetchPhotos(date: date)
    }

    public static func fetchPhotoMetadata(with startDate: Date, endDate: Date) async -> [PhotoMetadata]? {
        await Database.shared.bootUp()
        return await Database.shared.fetchPhotos(startDate: startDate, endDate: endDate)
    }
    
    public static func fetchAllPhotoMetadata() async -> [PhotoMetadata]? {
        await Database.shared.bootUp()
        return await Database.shared.fetchAllPhotos()
    }
    
    public static func deletePhoto(fileName: String) async {
        await Database.shared.bootUp()
        await Database.shared.deletePhoto(fileName: fileName)
        PhotoFileManager.deleteFile(fileName: fileName)
    }
    
    public static func deletePhotos(fileNames: [String]) async {
        await Database.shared.bootUp()
        for fileName in fileNames {
            await Database.shared.deletePhoto(fileName: fileName)
            PhotoFileManager.deleteFile(fileName: fileName)
        }
    }
    
    public static func fetchPhoto(fileName: String) async -> Data? {
        return PhotoFileManager.fetchFile(fileName: fileName)
    }
    
    public static func deleteTodaysPhoto() async {
        await Database.shared.bootUp()
        await Database.shared.deletePhotos(startDate: Date(), endDate: Date())
    }
    
    public static func deleteThisWeeksPhotos() async {
        await Database.shared.bootUp()
        if let range = Date.currentWeekRange() {
            await Database.shared.deletePhotos(startDate: range.start, endDate: range.end)
        }
    }
    
    public static func deleteThisMonthsPhotos() async {
        await Database.shared.bootUp()
        if let range = Date.currentMonthRange() {
            await Database.shared.deletePhotos(startDate: range.start, endDate: range.end)
        }
    }
    
    public static func deleteAllPhotos() async {
        await Database.shared.bootUp()
        await Database.shared.deleteAllPhotos()
        PhotoFileManager.deleteAllFiles()
    }
    
    // TODO: Smart Delete Images
}

extension Date {
    
    static func currentWeekRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
              let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)
        else { return nil }
        
        return (start: calendar.startOfDay(for: startOfWeek),
                end: calendar.startOfDay(for: endOfWeek))
    }
    
    static func currentMonthRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        
        guard let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start,
              let range = calendar.range(of: .day, in: .month, for: Date())
        else {
            return nil
        }
        
        let lastDay = range.count - 1
        guard let endOfMonth = calendar.date(byAdding: .day, value: lastDay, to: startOfMonth) else { return nil }
        
        return (start: calendar.startOfDay(for: startOfMonth),
                end: calendar.startOfDay(for: endOfMonth))
    }
    
}
