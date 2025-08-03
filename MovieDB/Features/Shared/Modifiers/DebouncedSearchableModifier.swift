//
//  DebouncedSearchableModifier.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/26/25.
//

import SwiftUI

final class DebouncedViewModel: ObservableObject {
    @Published var input: String = ""
}

struct DebouncedModifier: ViewModifier {
    
    @State private var viewModel = DebouncedViewModel()
    
    @Binding var text: String
    @Binding var debouncedText: String
    let debounceTimeInSeconds: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .onReceive(viewModel.$input.debounce(for: RunLoop.SchedulerTimeType.Stride(debounceTimeInSeconds), scheduler: RunLoop.main)) { value in
                debouncedText = value
            }
            .onChange(of: text) { _, newValue in
                viewModel.input = newValue
            }
    }
}

extension View {
    public func debounced(text: Binding<String>, debouncedText: Binding<String>, debounceTimeInSeconds: TimeInterval = 0.5) -> some View {
        modifier(DebouncedModifier(text: text, debouncedText: debouncedText, debounceTimeInSeconds: debounceTimeInSeconds))
    }
}

struct OnDebouncedSearchableModifier: ViewModifier {
    
    @State private var text: String = ""
    @State var debouncedText: String = ""
    
    let debounceTimeInSeconds: TimeInterval
    let onDebounced: (String) -> Void
    
    func body(content: Content) -> some View {
        content
            .searchable(text: $text, placement: .navigationBarDrawer, prompt: "Search")
            .debounced(text: $text, debouncedText: $debouncedText, debounceTimeInSeconds: debounceTimeInSeconds)
            .onChange(of: debouncedText) { _, newValue in
                onDebounced(newValue)
            }
    }
}

extension View {
    public func searchable(debouncingBy debounceTimeInSeconds: TimeInterval = 0.5, onDebounced: @escaping (String) -> Void) -> some View {
        modifier(OnDebouncedSearchableModifier(debounceTimeInSeconds: debounceTimeInSeconds, onDebounced: onDebounced))
    }
}
