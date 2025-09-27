//
//  FilePersister.swift
//  MediaCaptureKit
//
//  Created by William Stankus on 9/26/25.
//
import Foundation

actor PhotoFileManager {
    
    static func persistFile(imageData: Data, uuidString: String) {
        guard let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }
        
        let fileURL = directory.appendingPathComponent(uuidString)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("! --- Error Persiting File --- !")
        }
        
    }
    
    static func fetchFile(fileName: String) -> Data? {
        guard let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return nil }
        
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("! -- Error Fetching File -- !")
            return nil
        }
    }
    
    
    static func deleteFile(fileName: String) {
        guard let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }

        let fileURL = directory.appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("! --- Error Removing File --- ! \(error.localizedDescription)")
        }
    }
    
    static func deleteAllFiles() {
        guard let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("! --- Error Removing All Files --- ! \(error.localizedDescription)")
        }
    }
}
