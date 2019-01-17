require 'rails_helper'
require 'wgbh/batch_ingest/pbcore_xml_mapper'

RSpec.describe WGBH::BatchIngest::PBCoreXMLMapper do
  let(:mapper) { described_class.new(pbcore_instantiation.to_xml) }
  let(:pbcore_instantiation) { FactoryBot.build(:pbcore_instantiation_document) }

  describe '#physical_instantiation_attributes' do
    it 'maps the attributes correctly' do
      require 'pry'; binding.pry
      expect{ mapper.physical_instantiation_attributes }
    end
  end
end
