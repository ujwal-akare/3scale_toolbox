require 'rspec/expectations'

RSpec::Matchers.define :be_subset_of do |superset|
  match do |subset|
    subset.all? do |subset_elem|
      superset.find do |super_set_elem|
        ThreeScaleToolbox::Helper.compare_hashes(subset_elem, super_set_elem, @keys)
      end
    end
  end

  chain :comparing_keys do |keys|
    @keys = keys
  end
end

RSpec::Matchers.define :excluding_policies do |policy_name|
  match do |policies_object|
    return true unless policies_object.key?('policies_config')

    policies_object['policies_config'].all? do |policy|
      policy[:name] != policy_name
    end
  end
end
