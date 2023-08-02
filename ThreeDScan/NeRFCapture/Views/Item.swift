/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct Item: Codable, Identifiable {
    
    let name: String
    let id = UUID()
    let url: URL

}

extension Item: Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
}
