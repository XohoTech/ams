require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

RSpec.describe AAPB::BatchIngest::PBCoreXMLItemIngester, reset_data: false do
  let(:ingester_class) { described_class }
  let(:submitter) { create(:user) }
  let(:batch) { build(:batch, submitter_email: submitter.email) }
  let(:sample_source_location) { File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' ) }
  let(:batch_item) { build(:batch_item, batch: batch, source_location: sample_source_location)}

  it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"

  describe '#ingest' do
    context 'given a PBCore Description Document with Contributors, Digital Instantiations, and a Physical Instantiation' do
      # Before all, build PBCore XML containing Contributors, Digital
      # Instantiations, and a Physical Instantiation and ingest it. Use the
      # PBCore XML as the source data for a BatchItem instance, and then use the
      # PBCoreXMLItemIngester to ingest the BatchItem. The return value is an
      # Asset model instance on which we can write our expectations.
      before :all do
        # Build the PBCore XML
        pbcore_xml = FactoryBot.build(
          :pbcore_description_document,
          identifiers: [
            build(:pbcore_identifier, :aapb)
          ],
          contributors: build_list(:pbcore_contributor, 5),
          instantiations: [
            build_list(:pbcore_instantiation, 5, :digital),
            build(:pbcore_instantiation, :physical)
          ].flatten
        ).to_xml

        # Use the PBCore XML as the source data for a BatchItem.
        batch_item = build(
          :batch_item,
          batch: build(:batch, submitter_email: create(:user).email),
          source_location: nil,
          source_data: pbcore_xml
        )

        # Ingest the BatchItem and use the returned Asset instance for testing.
        @asset = described_class.new(batch_item).ingest
      end

      it 'ingests the Asset and the Contributions' do
        contributions = @asset.members.select { |member| member.is_a? Contribution }
        expect(contributions.count).to eq 5
      end

      it 'ingests the Asset and the Digital Instantiations' do
        digital_instantiations = @asset.members.select { |member| member.is_a? DigitalInstantiation }
        expect(digital_instantiations.count).to eq 5
      end

      it 'ingests the Asset and the Physical Instantiations' do
        digital_instantiations = @asset.members.select { |member| member.is_a? PhysicalInstantiation }
        expect(digital_instantiations.count).to eq 1
      end
    end
  end
end