# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/members_page.rb'

describe 'member data' do
  url = 'http://www.sxmparliament.org/organization/members-of-parliament.html'
  around { |test| VCR.use_cassette(url.split('/').last, &test) }

  subject do
    MembersPage.new(response: Scraped::Request.new(url: url).response)
               .members
               .find { |row| row.id == id }
  end

  describe 'Member with Drs. prefix' do
    let(:id) { 'rodolphe.samuel' }
    it 'should return the expected data' do
      subject.to_h.must_equal(
        id:               id,
        name:             'Rodolphe E. Samuel',
        honorific_prefix: 'drs.',
        image:            'http://www.sxmparliament.org/images/samuel.jpg',
        party:            'National Alliance',
        email:            'rodolphe.samuel@sxmparliament.org',
        source:           'http://www.sxmparliament.org/organization/members-of-parliament.html'
      )
    end
  end
end
