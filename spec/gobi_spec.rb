# spec/gobi_spec.rb
require 'pathname'
require 'gobi'
describe GOBI do
  let(:incoming_file) { './data/incoming/ebook0223.ord' }
  let(:processed_incoming_file) { './data/incoming/processed/ebook0223.ord' }
  let(:processed_DEG_file) { './data/gobi_processed/ebookDEG0223.ord' }
  let(:processed_EBS_file) { './data/gobi_processed/ebookEBS0223.ord' }

  it 'seeds data incoming with fixture data' do
    GOBI.seed!
    expect(Pathname.new(incoming_file)).to exist
  end

  it 'Deletes fixture data from incoming' do
    GOBI.refresh!
    GOBI.clear!
    expect(Pathname.new(incoming_file)).to_not exist
  end

  it 'refreshes fixture data from incoming' do
    GOBI.refresh!
    expect(Pathname.new(incoming_file)).to exist
  end

  it 'splits order record file into multiple provider order record files' do
    GOBI.refresh!
    GOBI.process!(incoming_file)
    expect(Pathname.new(processed_DEG_file)).to exist
    expect(Pathname.new(processed_EBS_file)).to exist
    expect(Pathname.new(processed_incoming_file)).to exist
    GOBI.clear!
  end
end
