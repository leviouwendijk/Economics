import Foundation
import Extensions
import plate

extension QuotaTierContent {
    public func standardPriceStringReplacements(roundTo multiple: Double = 10) -> [StringTemplateReplacement] {
        let prognosisPriceRounded = levels.prognosis.rate
        .rounded(to: multiple, direction: .down, by: 1.0).price
        .integer()

        let suggestionPriceRounded = levels.suggestion.rate
        .rounded(to: multiple, direction: .down, by: 1.0).price
        .integer()

        let singularPriceRounded = levels.singular.rate
        .rounded(to: multiple, direction: .down, by: 1.0).price
        .integer()

        return [
            StringTemplateReplacement(
                placeholders: ["prognosis_price"], 
                replacement: prognosisPriceRounded.string(),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["suggestion_price"], 
                replacement: suggestionPriceRounded.string(),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["singular_price"], 
                replacement: singularPriceRounded.string(),
                initializer: .auto
            ),
        ]
    }

    public func locationStringReplacements() -> [StringTemplateReplacement] {
        let prognosisLocationStrings = SessionLocationString(for: tier, estimationObject: self.levels.prognosis.estimation)
        let suggestionLocationStrings = SessionLocationString(for: tier, estimationObject: self.levels.suggestion.estimation)
        let singularLocationStrings = SessionLocationString(for: tier, estimationObject: self.levels.singular.estimation)

        func suffix(_ count: Int) -> String {
            return count > 1 ? "sessies" : "sessie"
        }   

        let prefix = "estimation"

        let progCount = levels.prognosis.estimation.count.string()
        let progLocal = levels.prognosis.estimation.local.string()

        let suggCount = levels.suggestion.estimation.count.string()
        let suggLocal = levels.suggestion.estimation.local.string()

        let singCount = levels.singular.estimation.count.string()
        let singLocal = levels.singular.estimation.local.string()

        let suffixedProgCount = "\(progCount) \(suffix(levels.prognosis.estimation.count))"
        let suffixedSuggCount = "\(suggCount) \(suffix(levels.suggestion.estimation.count))"
        let suffixedSingCount = "\(singCount) \(suffix(levels.singular.estimation.count))"

        return [
            // prognosis
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_count"], 
                replacement: progCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_count_suffix"], 
                replacement: suffixedProgCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_local"], 
                replacement: progLocal,
                initializer: .auto
            ),

            // suggestion
            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_count"], 
                replacement: suggCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_count_suffix"], 
                replacement: suffixedSuggCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_local"], 
                replacement: suggLocal,
                initializer: .auto
            ),

            // singular
            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_count"], 
                replacement: singCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_count_suffix"], 
                replacement: suffixedSingCount,
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_local"], 
                replacement: singLocal,
                initializer: .auto
            ),

            // particularized location strings
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_remote_string"], 
                replacement: prognosisLocationStrings.split(for: .remote),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_local_string"], 
                replacement: prognosisLocationStrings.split(for: .local),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_prognosis_full_string"], 
                replacement: prognosisLocationStrings.combined(),
                initializer: .auto
            ),

            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_remote_string"], 
                replacement: suggestionLocationStrings.split(for: .remote),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_local_string"],
                replacement: suggestionLocationStrings.split(for: .local),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_suggestion_full_string"],
                replacement: suggestionLocationStrings.combined(),
                initializer: .auto
            ),

            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_remote_string"], 
                replacement: singularLocationStrings.split(for: .remote),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_local_string"],
                replacement: singularLocationStrings.split(for: .local),
                initializer: .auto
            ),
            StringTemplateReplacement(
                placeholders: ["\(prefix)_singular_full_string"],
                replacement: singularLocationStrings.combined(),
                initializer: .auto
            ),
        ]
    }
}

extension CustomQuota {
    public func kilometerCodeReplacement(for tier: QuotaTierType) -> [StringTemplateReplacement] {
        let kilometerCode = KilometerCodes.encrypt(for: travelCost.kilometers)

        return [
            // kilometer code
            StringTemplateReplacement(
                placeholders: ["encrypted_kilometer_code"], 
                replacement: kilometerCode,
                initializer: .auto
            ),
        ]
    }

    public func expirationReplacements() -> [StringTemplateReplacement] {
        return [
            StringTemplateReplacement(
                placeholders: ["start_date"], 
                replacement: expiration.dates.start.conforming(),
                initializer: .auto
            ),
            
            StringTemplateReplacement(
                placeholders: ["end_date"], 
                replacement: expiration.dates.end.conforming(),
                initializer: .auto
            ),
        ]
    }
}

// extension QuotaTierContent {
    // public func replacements(roundTo multiple: Double = 10) -> [StringTemplateReplacement] {
    //     let prefix = tier.rawValue

    //     return [
    //         // base
    //         // ---------------------------------------------------
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_base_prognosis"], 
    //             replacement: "\(base.rounded(to: multiple).prognosis)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_base_suggestion"], 
    //             replacement: "\(base.rounded(to: multiple).suggestion)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_base_singular"], 
    //             replacement: "\(base.rounded(to: multiple).base)",
    //             initializer: .auto
    //         ),

    //         // cost
    //         // ---------------------------------------------------
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_cost_prognosis"], 
    //             replacement: "\(cost.rounded(to: multiple).prognosis)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_cost_suggestion"], 
    //             replacement: "\(cost.rounded(to: multiple).suggestion)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_cost_singular"], 
    //             replacement: "\(cost.rounded(to: multiple).base)",
    //             initializer: .auto
    //         ),

    //         // price
    //         // (for now, only price is relevant for quota)
    //         // ---------------------------------------------------
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_price_prognosis"], 
    //             replacement: "\(price.rounded(to: multiple).prognosis)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_price_suggestion"], 
    //             replacement: "\(price.rounded(to: multiple).suggestion)",
    //             initializer: .auto
    //         ),
    //         StringTemplateReplacement(
    //             placeholders: ["\(prefix)_price_singular"], 
    //             replacement: "\(price.rounded(to: multiple).base)",
    //             initializer: .auto
    //         ),
    //     ]
    // }
// }
