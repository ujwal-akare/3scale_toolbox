RSpec.describe ThreeScaleToolbox::Helper do
  include_context :random_name

  context '#filter_params' do
    let(:source_params) { %i[param1 param2 param3] }

    let(:source_obj) do
      source_params.each_with_object({}) do |key, target|
        target[key] = random_lowercase_name
      end
    end

    it 'all expected params are copied' do
      target_obj = described_class.filter_params source_params, source_obj
      expect(target_obj).to include(*source_params)
    end

    it 'extra params are not copied' do
      extra_params = {
        some_weird_param: 'value0',
        some_other_weird_param: 'value1'
      }
      target_obj = described_class.filter_params(source_params, source_obj.merge(extra_params))
      expect(target_obj).to include(*source_params)
      expect(target_obj).not_to include(*extra_params)
    end

    it 'missing params are not copied' do
      missing_params = source_params.slice(1..2)
      missing_params.each do |key|
        source_obj.delete(key)
      end
      target_obj = described_class.filter_params(source_params, source_obj)
      expect(target_obj).to include(*(source_params - missing_params))
      expect(target_obj).not_to include(*missing_params)
    end
  end

  context '#array_difference' do
    subject { described_class.array_difference(ary, other_ary) { |e1, e2| e1 == e2 } }

    context '[a] - [b]' do
      let(:ary) { [1] }
      let(:other_ary) { [2] }

      it 'should be [a]' do
        expect(subject).to include(1)
      end
    end

    context '[] - [b]' do
      let(:ary) { [] }
      let(:other_ary) { [1] }

      it 'should be []' do
        expect(subject).to be_empty
      end
    end

    context '[a] - []' do
      let(:ary) { [1] }
      let(:other_ary) { [] }

      it 'should be [a]' do
        expect(subject).to include(1)
      end
    end

    context '[a, b] - [b]' do
      let(:ary) { [1, 2] }
      let(:other_ary) { [2] }

      it 'should be [a]' do
        expect(subject).to include(1)
      end
    end
  end

  context '#compare_hashes' do
    subject { described_class.compare_hashes(first, second, keys) }

    context 'compare {a:1, b:1, c:1}, {a:1, c:2} ' do
      let(:first) { { a: 1, b: 1, c: 1 } }
      let(:second) { { a: 1, c: 2 } }

      context 'with keys [a]' do
        let(:keys) { [:a] }
        it 'should match' do
          expect(subject).to be_truthy
        end
      end

      context 'with keys [b]' do
        let(:keys) { [:b] }
        it 'should not match' do
          expect(subject).to be_falsey
        end
      end

      context 'with keys [c]' do
        let(:keys) { [:c] }
        it 'should not match' do
          expect(subject).to be_falsey
        end
      end

      context 'with keys [a,b]' do
        let(:keys) { %i[a b] }
        it 'should not match' do
          expect(subject).to be_falsey
        end
      end

      context 'with keys [a,c]' do
        let(:keys) { %i[a c] }
        it 'should not match' do
          expect(subject).to be_falsey
        end
      end
    end
  end

  context '#backend_metric_link_parser' do
    subject { described_class.backend_metric_link_parser(link) }

    context 'on good link' do
      let(:link) { 'https://example.com/admin/api/backend_apis/3545/metrics/948744.json' }
      it 'captures backend' do
        expect(subject).to eq '3545'
      end
    end

    context 'on unexpected link' do
      let(:link) { 'https://example.com/metrics/948744.json' }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'on nil link' do
      let(:link) { nil }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
