import Foundation
import ServiceManagement

/// Wraps `SMAppService.mainApp` for managing the app's launch-at-login
/// registration. Reads/writes the system status directly — there's no
/// `UserDefaults` cache to drift out of sync.
///
/// The first `register()` on an ad-hoc signed bundle prompts the user
/// once; subsequent calls succeed silently. Bundles living outside a
/// stable location (`/Applications`, `~/Applications`) can register but
/// the system may refuse to actually launch them at login.
@MainActor
enum LaunchAtLogin {
    /// Whether the system currently has this app registered to launch at login.
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Idempotent toggle. No-op if already in the desired state. Throws
    /// if the system rejects the change (e.g. user denied the consent
    /// prompt, status is `.requiresApproval`, etc.).
    static func setEnabled(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        if enabled, service.status != .enabled {
            try service.register()
        } else if !enabled, service.status == .enabled {
            try service.unregister()
        }
    }
}
