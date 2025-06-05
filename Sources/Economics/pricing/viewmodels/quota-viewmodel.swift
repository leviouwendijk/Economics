import Foundation
import Combine

// @MainActor
// public class QuotaViewModel: ObservableObject {
//     @Published public var customQuotaInputs: CustomQuotaInputs
    
//     @Published public private(set) var loadedQuota: CustomQuota? = nil
//     @Published public private(set) var isLoading: Bool = false
    
//     private var cancellables = Set<AnyCancellable>()

//     // private var debounceQuotaTask: Task<Void, Never>? = nil
//     // private let debounceInterval: TimeInterval = 0.2
    
//     public init() {
//         self.customQuotaInputs = CustomQuotaInputs(
//             base: "350",
//             prognosis: SessionCountEstimationInputs(
//                 // type: .prognosis,
//                 count: "5",
//                 local: "4"
//             ),
//             suggestion: SessionCountEstimationInputs(
//                 // type: .suggestion,
//                 count: "3",
//                 local: "2"
//             ),
//             singular: SessionCountEstimationInputs(
//                 count: "1",
//                 local: "0"
//             ),
//             travelCost: TravelCostInputs(
//                 kilometers: "",
//                 speed: "80.0",
//                 rates: TravelCostRatesInputs(
//                     travel: "0.25", 
//                     time: "105"
//                 ),
//                 roundTrip: true
//             )
//         )
    
//         $customQuotaInputs
//           .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
//           .sink { [weak self] inputs in
//               guard let self = self else { return }

//               self.isLoading = true
//               self.loadedQuota = nil

//               DispatchQueue.global(qos: .userInitiated).async {
//                   do {
//                       let q = try inputs.customQuotaEstimation()
//                       DispatchQueue.main.async {
//                           self.loadedQuota = q
//                           self.isLoading = false
//                       }
//                   } catch {
//                       DispatchQueue.main.async {
//                           self.loadedQuota = nil
//                           self.isLoading = false
//                       }
//                   }
//               }
//           }
//           .store(in: &cancellables)
//     }

//     // public func compute() {
//     //     isLoading = true
//     //     loadedQuota = nil
        
//     //     let inputs = self.customQuotaInputs
//     //     DispatchQueue.global(qos: .userInitiated).async {
//     //         do {
//     //             let q = try inputs.customQuotaEstimation()
//     //             DispatchQueue.main.async {
//     //                 self.loadedQuota = q
//     //                 self.isLoading = false
//     //             }
//     //         } catch {
//     //             DispatchQueue.main.async {
//     //                 self.loadedQuota = nil
//     //                 self.isLoading = false
//     //             }
//     //         }
//     //     }
//     // }
// }

@MainActor
public class QuotaViewModel: ObservableObject {
    @Published public var customQuotaInputs: CustomQuotaInputs

    @Published public private(set) var loadedQuota: CustomQuota? = nil

    @Published public private(set) var isLoading: Bool = false

    private var debounceQuotaTask: Task<Void, Never>? = nil
    private let debounceInterval: TimeInterval = 0.2

    public init() {
        self.customQuotaInputs = CustomQuotaInputs(
            base: "350",
            prognosis: SessionCountEstimationInputs(count: "5", local: "4"),
            suggestion: SessionCountEstimationInputs(count: "3", local: "2"),
            singular: SessionCountEstimationInputs(count: "1", local: "0"),
            travelCost: TravelCostInputs(
                kilometers: "",
                speed: "80.0",
                rates: TravelCostRatesInputs(travel: "0.25", time: "105"),
                roundTrip: true
            )
        )

        scheduleQuotaComputation()

        _ = $customQuotaInputs
            .sink { [weak self] _ in
                self?.scheduleQuotaComputation()
            }
    }

    private func scheduleQuotaComputation() {
        debounceQuotaTask?.cancel()

        isLoading = true
        loadedQuota = nil

        let snapshot = customQuotaInputs

        debounceQuotaTask = Task { [weak self] in
            guard let self = self else { return }

            try? await Task.sleep(nanoseconds: UInt64(self.debounceInterval * 1_000_000_000))

            guard !Task.isCancelled else { return }

            let result = await self.computeQuota(offMain: snapshot)

            guard !Task.isCancelled else { return }

            self.loadedQuota = result
            self.isLoading = false
        }
    }

    @Sendable
    private func computeQuota(offMain inputs: CustomQuotaInputs) async -> CustomQuota? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let quota = try inputs.customQuotaEstimation()
                    continuation.resume(returning: quota)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
