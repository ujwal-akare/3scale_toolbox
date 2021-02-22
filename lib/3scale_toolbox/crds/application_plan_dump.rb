module ThreeScaleToolbox
  module CRD
    module ApplicationPlanSerializer
      def to_cr
        {
          'name' => name,
          'appsRequireApproval' => approval_required?,
          'trialPeriod' => trial_period_days,
          'setupFee' => setup_fee,
          'custom' => custom,
          'state' => state,
          'costMonth' => cost_per_month,
          'pricingRules' => pricing_rules.map(&:to_cr),
          'limits' => limits.map(&:to_cr)
        }
      end
    end
  end
end
