import Foundation
import Combine

@MainActor
public class QuotaViewModel: ObservableObject {
    @Published public var customQuotaInputs: CustomQuotaInputs
    
    @Published public private(set) var loadedQuota: CustomQuota? = nil
    @Published public private(set) var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.customQuotaInputs = CustomQuotaInputs(
            base: "350",
            prognosis: SessionCountEstimationInputs(
                type: .prognosis,
                count: "5",
                local: "4"
            ),
            suggestion: SessionCountEstimationInputs(
                type: .suggestion,
                count: "3",
                local: "2"
            ),
            travelCost: TravelCostInputs(
                kilometers: "",
                speed: "80.0",
                rates: TravelCostRatesInputs(
                    travel: "0.25", 
                    time: "105"
                ),
                roundTrip: true
            )
        )
    
        $customQuotaInputs
            // Debounce so we only fire 200ms after the user stops typing any field:
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] inputs in
                self?.computeQuotaFromInputs(inputs)
            }
            .store(in: &cancellables)
    }
    
    private func computeQuotaFromInputs(_ inputs: CustomQuotaInputs) {
        do {
            let q = try inputs.customQuotaEstimation()

            self.isLoading = true
            self.loadedQuota = nil

            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.loadedQuota = q
                    self.isLoading = false
                }
            }
        }
        catch {
            self.loadedQuota = nil
        }
    }
}
