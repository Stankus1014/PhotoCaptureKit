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
    
    public static func deleteAllPhotos() async {
        await Database.shared.bootUp()
        await Database.shared.deleteAllPhotos()
        PhotoFileManager.deleteAllFiles()
    }
    
    // TODO: Smart Delete Images
    
}
