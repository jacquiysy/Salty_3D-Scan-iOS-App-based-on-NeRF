/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GridView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var imageViewModel: ImageViewModel

    private static let initialColumns = 3
    @State private var isAddingPhoto = false
    @State private var isEditing = false

    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns
    
    @State private var toSearch = ""
    
    @State private var showView = false
    @State private var showDetailView = false
    
    private var columnsTitle: String {
        gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
    }
    
    var searchResults: [Item] {
        if toSearch.isEmpty {
            return dataModel.items
        } else {
            return dataModel.items.filter { $0.name.lowercased().contains(toSearch.lowercased()) }
        }
    }
    
    var imageResults: [Item] {
        if toSearch.isEmpty {
            return imageViewModel.imageModels
        } else {
            return imageViewModel.imageModels.filter { $0.name.lowercased().contains(toSearch.lowercased()) }
        }
    }
    
//    GridView.isFavourite = true
    static var isFavourite = false
//    @EnvironmentObject var favDataModel: DataModel
    
    var body: some View {
        VStack {
            if isEditing {
                ColumnStepper(title: columnsTitle, range: 1...8, columns: $gridColumns)
                    .padding()
            }
            
            Button(action: { showView = true }){
                Text("Local Models")
            }
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(searchResults) { item in
                        GeometryReader { geo in
                            NavigationLink(destination: DetailView(item: item)) {
                                GridItemView(size: geo.size.width, item: item)
                            }
                        }
                        .cornerRadius(8.0)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) {
                            if isEditing {
                                Button {
                                    withAnimation {
                                        dataModel.removeItem(item)
                                    }
                                } label: {
                                    Image(systemName: "xmark.square.fill")
                                        .font(Font.title)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .red)
                                }
                                .offset(x: 7, y: -7)
                            }
                        }
                    }
                }
                .padding()
            }
            Button(action: { showView = true }){
                Text("Generated Models")
            }
            //            GridView.isFavourite = true
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(imageResults) { item in
                        GeometryReader { geo in
                            NavigationLink( destination: DestinationView(modelName: (item.name as NSString).deletingPathExtension + ".obj")) {
                                GridItemView(size: geo.size.width, item: item)
                            }
                        }.onTapGesture {
                            tabSelection = 4
                        }
                        .cornerRadius(8.0)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) {
                            if isEditing {
                                Button {
                                    withAnimation {
                                        dataModel.removeItem(item)
                                    }
                                } label: {
                                    Image(systemName: "xmark.square.fill")
                                        .font(Font.title)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .red)
                                }
                                .offset(x: 7, y: -7)
                            }
                        }
                    }
                }
                .padding()
            }
//            .onAppear {
//                imageViewModel.fetchImageModels()
//            }
        }
        .navigationBarTitle("Gallery")
        .searchable(text: $toSearch)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddingPhoto) {
            PhotoPicker()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingPhoto = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(isEditing)
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        @State var tabSelection = 5
        GridView(tabSelection: $tabSelection).environmentObject(DataModel()).environmentObject(ImageViewModel())
            .previewDevice("iPad (8th generation)")
    }
}
 
