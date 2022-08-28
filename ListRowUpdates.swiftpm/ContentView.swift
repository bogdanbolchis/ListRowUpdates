import SwiftUI

struct ContentView: View {
    @StateObject var store = RowStore()
    
    var body: some View {
        List {
            Section(header: Text("Modes of transportation"), content: {
                ForEach(store.rows) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.text)
                                .font(.headline)
                            Text(row.detail)
                                .font(.caption)
                                .id(row.text + row.detail)
                                .transition(.opacity.combined(with: .scale))
                        }
                        Spacer()
                        Image(systemName: row.imageName)
                    }
                }
            })
        }.refreshable {
            await store.loadRows()
        }
        .animation(.default, value: store.rows)
    }
}

struct Row: Identifiable, Equatable {
    var text: String
    var detail: String {
        String("Updates: \(updatesCount)")
    }
    var updatesCount: Int = 0
    var imageName: String
    var id = UUID().uuidString
}

class RowStore: ObservableObject {
    @Published var rows = [
        Row(text: "Bicycle", imageName: "bicycle"),
        Row(text: "Airplane", imageName: "airplane"),
        Row(text: "Car", imageName: "car"),
        Row(text: "Bus", imageName: "bus"),
        Row(text: "Tram", imageName: "tram"),
        Row(text: "Ferry", imageName: "ferry"),
        Row(text: "Walking", imageName: "figure.walk")
    ]
    
    func loadRows() async {
        Task.detached { // simulate work in the background
            var rows = self.rows
            
            if var randomRow = rows.randomElement(), let index = rows.firstIndex(of: randomRow) {
                randomRow.updatesCount += 1
                rows.remove(at: index)
                rows.insert(randomRow, at: index)
            }
            
            try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            let updatedRows = rows // please the compiler by not capturing the `rows` variable in the following closure
            
            DispatchQueue.main.async {
                self.rows = updatedRows
            }
        }
    }
}
