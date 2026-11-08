//
//  HomeGridLibrary.swift
//  Rivulet
//

import Foundation

/// The library Home ends with as one poster grid, the library page's own
/// (Settings > Appearance > Home > Grid). Off by default; device-wide.
enum HomeGridLibrary {

    /// Posted after a choice. Home rebuilds its grid on it.
    static let changedNotification = Notification.Name("homeGridLibraryChanged")

    private static let key = "homeGridLibrary"

    /// The chosen library's `settingsKey`, kept when its server is offline.
    static var selectedKey: String? { UserDefaults.standard.string(forKey: key) }

    static func select(_ library: MediaLibrary?) {
        if let library {
            UserDefaults.standard.set(library.settingsKey, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        NotificationCenter.default.post(name: changedNotification, object: nil)
    }

    /// Libraries Home can end with: the selected Plex server's on Home, then
    /// the other servers' in the sidebar, video and music only.
    @MainActor static var candidates: [MediaLibrary] {
        var libraries: [MediaLibrary] = []
        if let plex = MediaProviderRegistry.shared.plexProvider {
            libraries += PlexDataStore.shared.librariesPinnedToHome.map { PlexMediaMapper.library($0, providerID: plex.id) }
        }
        libraries += ServerDataStore.shared.visibleLibraries
        return libraries.filter { [.movies, .shows, .music, .mixed].contains($0.kind) }
    }

    @MainActor static var selected: MediaLibrary? {
        selectedKey.flatMap { key in candidates.first { $0.settingsKey == key } }
    }
}
