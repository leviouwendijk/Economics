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
                // type: .prognosis,
                count: "5",
                local: "4"
            ),
            suggestion: SessionCountEstimationInputs(
                // type: .suggestion,
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
          .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
          .sink { [weak self] inputs in
              guard let self = self else { return }

              self.isLoading = true
              self.loadedQuota = nil

              DispatchQueue.global(qos: .userInitiated).async {
                  do {
                      let q = try inputs.customQuotaEstimation()
                      DispatchQueue.main.async {
                          // ← now back on main to update the UI
                          self.loadedQuota = q
                          self.isLoading = false
                      }
                  } catch {
                      DispatchQueue.main.async {
                          self.loadedQuota = nil
                          self.isLoading = false
                      }
                  }
              }
          }
          .store(in: &cancellables)
    }

    // public func compute() {
    //     isLoading = true
    //     loadedQuota = nil
        
    //     let inputs = self.customQuotaInputs
    //     DispatchQueue.global(qos: .userInitiated).async {
    //         do {
    //             let q = try inputs.customQuotaEstimation()
    //             DispatchQueue.main.async {
    //                 self.loadedQuota = q
    //                 self.isLoading = false
    //             }
    //         } catch {
    //             DispatchQueue.main.async {
    //                 self.loadedQuota = nil
    //                 self.isLoading = false
    //             }
    //         }
    //     }
    // }
}
