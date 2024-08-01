//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI
import UniformTypeIdentifiers

// FileDocument for saving the solution solution
struct SolutionFile: FileDocument {
    var data = Data()
    
    init(configuration: ReadConfiguration) throws {
        if let newData = configuration.file.regularFileContents {
            data = newData
        }
    }
    
    // Implementation of FileDocument protocol follows:
    
    init(initialData: Data = Data()) {
        self.data = initialData
    }
    
    static var readableContentTypes = [UTType.data]
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
    
    static var writableContentTypes = [UTType.data]
}

struct ContentView: View {
    enum SolverState {
        case readyToSolve
        case solving
        case solutionReady
    }
    
    @State private var solverState: SolverState = .readyToSolve
    @State private var task: Task<Void, Never>?
    @State private var gameValue: GameValue = 0
    @State private var solution: SolutionFile?
    @State private var showingExporter = false
    @State private var writeError = ""
    @State private var showingWriteError = false
    
    var outcome: String {
        if gameValue == 0 {
            return "Game is a draw."
        } else if gameValue > 0 {
            let moves = (GameValue.max - gameValue + 1) / 2
            return "White wins in \(moves) moves."
        } else {
            let moves = (GameValue.max + gameValue + 1) / 2
            return "Black wins in \(moves) moves."
        }
    }
    
    var body: some View {
        VStack {
            switch solverState {
            case .readyToSolve:
                Text("Ready to solve")
                Button("Solve") {
                    solverState = .solving
                    task = Task.detached(priority: .low) {
                        let eval = Solver.solve()
                        gameValue = eval.evaluate(position: GamePosition.start)
                        solution = SolutionFile(initialData: eval.encode())
                        solverState = .solutionReady
                    }
                }
            case .solving:
                ProgressView("Solving ...")
            case .solutionReady:
                Text(outcome)
                Button("Export") {
                    showingExporter = true
                }
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: solution,
            contentType: .data,
            defaultFilename: "queahSolution.data"
            
        ) { result in
            switch result {
            case .success:
                solution = nil
                solverState = .readyToSolve
            case .failure(let error):
                writeError = error.localizedDescription
                showingWriteError = true
            }
        }
        .alert("Error Exporting File", isPresented: $showingWriteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(writeError)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
