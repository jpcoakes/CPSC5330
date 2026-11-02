// Homework2
// Eye Opener Coffee
//
// Joel Coakes
//

import SwiftUI

// Colors
let espresso = Color(red: 0.29, green: 0.18, blue: 0.12)
let latteFoam = Color(red: 0.97, green: 0.93, blue: 0.87)
let caramel = Color(red: 0.78, green: 0.52, blue: 0.29)

struct Coffee: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let price: Double
    let icon: String
}

let menu = [
    Coffee(name: "Classic Coffee", price: 3.00, icon: "classic-coffee"),
    Coffee(name: "Latte", price: 6.00, icon: "latte"),
    Coffee(name: "Cappuccino", price: 5.00, icon: "cappuccino"),
    Coffee(name: "Cold Brew", price: 4.00, icon: "cold-brew")
]

let milks = ["Skim", "2%", "Whole", "Oat"]
let syrups = ["None", "Vanilla", "Caramel", "Hazelnut", "Strawberry"]
let creamers = ["None", "Sweet Cream", "French Vanilla", "Caramel Cream"]

struct ContentView: View {
    @State private var selected: Coffee?
    @State private var addSugar = false
    @State private var addCreamer = false
    @State private var milk = "2%"
    @State private var isIced = false
    @State private var syrup = "None"
    @State private var coldBrewCreamer = "None"
    @State private var quantity = 1
    @State private var showConfirmation = false

    var total: Double {
        guard let selected else { return 0 }
        var price = selected.price
        switch selected.name {
        case "Classic Coffee":
            if addCreamer { price += 0.50 }
        case "Latte", "Cappuccino":
            if milk == "Oat" { price += 0.50 }
            if syrup != "None" { price += 0.50 }
        case "Cold Brew":
            if coldBrewCreamer != "None" { price += 0.50 }
            if syrup != "None" { price += 0.50 }
        default:
            break
        }
        return price * Double(quantity)
    }

    var body: some View {
        // ScrollView lets the whole screen scroll when an option expands
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()

                SectionTitle(text: "Menu")
                MenuItemCard(coffee: menu[0], isSelected: selected == menu[0]) {
                    selected = menu[0]
                }
                MenuItemCard(coffee: menu[1], isSelected: selected == menu[1]) {
                    selected = menu[1]
                }
                MenuItemCard(coffee: menu[2], isSelected: selected == menu[2]) {
                    selected = menu[2]
                }
                MenuItemCard(coffee: menu[3], isSelected: selected == menu[3]) {
                    selected = menu[3]
                }

                if let selected {
                    SectionTitle(text: "Customize your \(selected.name)")
                    optionsCard(for: selected)

                    orderSummary
                } else {
                    Text("Select a drink to get started")
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
            }
            .padding()
        }
        .background(latteFoam.ignoresSafeArea())
        .alert("Order Placed!", isPresented: $showConfirmation) {
            Button("OK") { resetOrder() }
        } message: {
            Text("Your \(quantity) × \(selected?.name ?? "") will be ready soon. Total: \(total, format: .currency(code: "USD"))")
        }
    }

    func optionsCard(for coffee: Coffee) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            switch coffee.name {
            case "Classic Coffee":
                Toggle("Sugar", isOn: $addSugar)
                Toggle("Creamer (+$0.50)", isOn: $addCreamer)

            case "Latte":
                milkPicker
                Picker("Temperature", selection: $isIced) {
                    Text("Hot").tag(false)
                    Text("Iced").tag(true)
                }
                .pickerStyle(.segmented)
                syrupPicker

            case "Cappuccino":
                milkPicker
                Label("Served hot only", image: "flame")
                    .foregroundStyle(caramel)
                syrupPicker

            case "Cold Brew":
                HStack {
                    Text("Creamer (+$0.50)")
                    Spacer()
                    Picker("Creamer", selection: $coldBrewCreamer) {
                        ForEach(creamers, id: \.self) { Text($0) }
                    }
                }
                syrupPicker

            default:
                EmptyView()
            }
        }
        .tint(caramel)
        .foregroundStyle(espresso)
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }

    // Milk Details
    var milkPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Milk (Oat +$0.50)")
            Picker("Milk", selection: $milk) {
                ForEach(milks, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    // Syrup Details
    var syrupPicker: some View {
        HStack {
            Text("Flavored Syrup (+$0.50)")
            Spacer()
            Picker("Syrup", selection: $syrup) {
                ForEach(syrups, id: \.self) { Text($0) }
            }
        }
    }

    var orderSummary: some View {
        VStack(spacing: 16) {
            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
            HStack {
                Text("Total")
                    .font(.title3.bold())
                Spacer()
                Text(total, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundStyle(caramel)
            }
            Button {
                showConfirmation = true
            } label: {
                Text("Place Order")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(espresso, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(latteFoam)
            }
        }
        .foregroundStyle(espresso)
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }

    func resetOrder() {
        selected = nil
        addSugar = false
        addCreamer = false
        milk = "2%"
        isIced = false
        syrup = "None"
        coldBrewCreamer = "None"
        quantity = 1
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("cappuccino")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(latteFoam)
                .padding(24)
                .background(Circle().fill(espresso))
            Text("Eye Opener Coffee")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(espresso)
            Text("Freshly brewed, just for you")
                .font(.subheadline)
                .foregroundStyle(caramel)
        }
        .padding(.top)
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.title2, design: .serif, weight: .semibold))
            .foregroundStyle(espresso)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MenuItemCard: View {
    let coffee: Coffee
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(coffee.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .frame(width: 44, height: 44)
                    .background(latteFoam, in: Circle())
                Text(coffee.name)
                    .font(.headline)
                Spacer()
                Text(coffee.price, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(caramel)
            }
            .foregroundStyle(espresso)
            .padding()
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? caramel : .clear, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
