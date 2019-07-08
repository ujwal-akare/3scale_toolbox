RSpec.describe ThreeScaleToolbox::ProxyLogger do
  class MyTestObject
    def method01(_param01)
      'result01'
    end
  end

  let(:proxied_object) { MyTestObject.new }
  subject { described_class.new(proxied_object) }

  it 'method01 exists' do
    expect(subject.method01('some_param')).to eq('result01')
  end

  it 'method01 method can be obtained from :method' do
    expect(subject.method(:method01).to_s).to eq(MyTestObject.new.method(:method01).to_s)
  end

  it 'undefined method02 raises method not found' do
    expect { subject.method02 }.to raise_error(NoMethodError)
  end

  it 'undefined method02 does not exist' do
    expect(subject.respond_to?(:method02)).to be_falsey
  end

  it 'proxy object class defined to be proxied object class' do
    expect(subject.class).to be(MyTestObject)
  end

  it 'method args in output' do
    expect do
      subject.method01('some_param')
    end.to output(/args \|\["some_param"\]\|/).to_stderr
  end

  it 'method return values in output' do
    expect do
      subject.method01('')
    end.to output(/response \|"result01"\|/).to_stderr
  end
end
