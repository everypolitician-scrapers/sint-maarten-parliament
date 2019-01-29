# frozen_string_literal: true
require 'scraped'
require_relative 'member_div'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :members do
    noko.css('section.article-content div#o1').map do |mem|
      fragment mem => MemberDiv
    end
  end
end
