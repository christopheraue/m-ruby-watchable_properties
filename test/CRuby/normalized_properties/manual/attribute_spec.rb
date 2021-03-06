describe NormalizedProperties::Manual::Attribute do
  before do
    stub_const('PropertyOwner', Class.new do
      extend NormalizedProperties

      attr_accessor :attribute
      normalized_attribute :attribute, type: 'Manual'
    end)
  end

  subject(:attribute){ owner.property :attribute }
  let(:owner){ PropertyOwner.new }

  before{ owner.attribute = 'attribute_value' }

  it{ is_expected.to have_attributes(owner: owner) }
  it{ is_expected.to have_attributes(name: :attribute) }
  it{ is_expected.to have_attributes(namespace: NormalizedProperties::Manual) }
  it{ is_expected.to have_attributes(to_s: "#{owner}#attribute") }
  it{ is_expected.to have_attributes(value: 'attribute_value') }

  describe "manual change of the attribute" do
    subject do
      owner.attribute = 'changed_value'
      owner.property(:attribute).changed! owner.attribute
    end

    before{ attribute.on(:changed){ |*args| callback.call *args } }
    let(:callback){ proc{} }

    before{ expect(callback).to receive(:call).with 'changed_value' }
    it{ is_expected.not_to raise_error }
    after{ expect(attribute.value).to eq 'changed_value' }
  end
end