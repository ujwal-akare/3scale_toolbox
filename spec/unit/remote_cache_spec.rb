RSpec.describe ThreeScaleToolbox::RemoteCache do
  let(:proxied_object) { double }
  let(:service_id) { 1 }
  let(:metrics) { [{'id' =>  1}, {'id' =>  2}] }
  let(:methods) { [{'id' =>  2}] }
  subject { described_class.new(proxied_object) }

  it 'list_metrics first call cache miss' do
    expect(proxied_object).to receive(:list_metrics).and_return(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
  end

  it 'list_metrics second call cache hit' do
    expect(proxied_object).to receive(:list_metrics).and_return(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
  end

  it 'list_metrics different service_id cache miss' do
    expect(proxied_object).to receive(:list_metrics).with(service_id).and_return(metrics)
    expect(proxied_object).to receive(:list_metrics).with(service_id+1).and_return([])
    expect(subject.list_metrics(service_id)).to eq(metrics)
    expect(subject.list_metrics(service_id+1)).to eq([])
  end

  context 'list_metrics returns error' do
    let(:error_response) { {'errors' => {}} }

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).twice.and_return(error_response)
      expect(subject.list_metrics(service_id)).to eq(error_response)
      expect(subject.list_metrics(service_id)).to eq(error_response)
    end
  end

  context 'list_metrics then create_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:create_metric)
      subject.list_metrics(service_id)
      subject.create_metric(service_id, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then update_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:update_metric)
      subject.list_metrics(service_id)
      subject.update_metric(service_id, 1, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then delete_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:delete_metric)
      subject.list_metrics(service_id)
      subject.delete_metric(service_id, 1)
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  it 'list_methods first call cache miss' do
    expect(proxied_object).to receive(:list_methods).and_return(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
  end

  it 'list_methods second call cache hit' do
    expect(proxied_object).to receive(:list_methods).and_return(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
  end

  it 'list_methods different service_id cache miss' do
    expect(proxied_object).to receive(:list_methods).with(service_id, 1).and_return(methods)
    expect(proxied_object).to receive(:list_methods).with(service_id+1, 1).and_return([])
    expect(subject.list_methods(service_id, 1)).to eq(methods)
    expect(subject.list_methods(service_id+1, 1)).to eq([])
  end

  context 'list_methods returns error' do
    let(:error_response) { {'errors' => {}} }

    it 'cache miss' do
      expect(proxied_object).to receive(:list_methods).twice.and_return(error_response)
      expect(subject.list_methods(service_id, 1)).to eq(error_response)
      expect(subject.list_methods(service_id, 1)).to eq(error_response)
    end
  end

  context 'list_methods then create_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:create_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.create_method(service_id, 1, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then update_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:update_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.update_method(service_id, 1, 10, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then delete_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:delete_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.delete_method(service_id, 1, 10)
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end
end
