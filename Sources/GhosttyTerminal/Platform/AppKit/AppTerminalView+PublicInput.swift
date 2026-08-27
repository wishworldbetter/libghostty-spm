//
//  AppTerminalView+PublicInput.swift
//  libghostty-spm
//
//  Public wrappers around `TerminalSurface` write paths so hosts can
//  inject bytes into the pty without reaching for internal API.
//

#if canImport(AppKit) && !canImport(UIKit)
    import AppKit

    extension AppTerminalView {
        /// Send raw UTF-8 text directly to the underlying pty (bypassing
        /// key translation). Use this for synthetic input like `\x1b[Z`
        /// (Shift+Tab / CSI Z) or multi-line paste-style injections.
        /// No-op when the surface has not been created yet.
        public func sendText(_ text: String) {
            surface?.sendText(text)
        }

        /// Invoke a named Ghostty binding action (e.g. "copy_to_clipboard",
        /// "clear_screen"). Returns true when the action dispatched.
        @discardableResult
        public func performBindingAction(_ action: String) -> Bool {
            surface?.performBindingAction(action) ?? false
        }

        /// Jump the viewport by a number of shell prompts.
        ///
        /// Negative offsets move toward older prompts and positive offsets move
        /// toward newer prompts. Prompt navigation requires shell integration.
        @discardableResult
        public func jumpToPrompt(by offset: Int16) -> Bool {
            surface?.jumpToPrompt(by: offset) ?? false
        }

        /// Reveal an absolute scrollback row, where zero is the first row.
        @discardableResult
        public func scrollToRow(_ row: UInt) -> Bool {
            surface?.scrollToRow(row) ?? false
        }

        /// Whether the grid currently holds a selection.
        public var hasSelection: Bool {
            surface?.hasSelection() ?? false
        }

        /// The selection's endpoints in active-area grid coordinates,
        /// visually ordered (top-left is the earlier endpoint regardless
        /// of drag direction). Nil without a selection or when an
        /// endpoint sits outside the active area.
        public var selectionRegion: (tlX: Int, tlY: Int, brX: Int, brY: Int, rectangle: Bool)? {
            guard let region = surface?.selectionRegion() else { return nil }
            return (region.tlX, region.tlY, region.brX, region.brY, region.rectangle)
        }

        /// Programmatically set the selection to a grid region. Unlike
        /// mouse selection this never triggers copy-on-select and never
        /// writes any clipboard.
        @discardableResult
        public func setSelectionRegion(
            tlX: Int,
            tlY: Int,
            brX: Int,
            brY: Int,
            rectangle: Bool = false
        ) -> Bool {
            surface?.setSelectionRegion(.init(
                tlX: tlX,
                tlY: tlY,
                brX: brX,
                brY: brY,
                rectangle: rectangle
            )) ?? false
        }

        /// Programmatically clear any selection, with no clipboard side
        /// effects.
        public func clearSelection() {
            surface?.clearSelection()
        }

        /// Search the screen and scrollback for `needle`, replacing any active
        /// search. An empty needle cancels without dismissing host search UI.
        @discardableResult
        public func search(_ needle: String) -> Bool {
            surface?.search(needle) ?? false
        }

        /// Search for the current selection; no-op without one.
        @discardableResult
        public func searchSelection() -> Bool {
            surface?.searchSelection() ?? false
        }

        /// Open search with no terms set, reported back through
        /// ``TerminalSurfaceSearchDelegate``.
        @discardableResult
        public func startSearch() -> Bool {
            surface?.startSearch() ?? false
        }

        /// Select the next or previous match of the active search.
        @discardableResult
        public func navigateSearch(forward: Bool) -> Bool {
            surface?.navigateSearch(forward: forward) ?? false
        }

        /// End the active search and clear its highlights.
        @discardableResult
        public func endSearch() -> Bool {
            surface?.endSearch() ?? false
        }
    }
#endif
