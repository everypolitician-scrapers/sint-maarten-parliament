#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'execjs'
require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.css('section.article-content div#o1').map do |mem|
      fragment mem => MemberDiv
    end
  end
end

class MemberDiv < Scraped::HTML
  field :id do
    email.sub(/@.*/, '')
  end

  field :name do
    noko.css('#org_title').text.tidy
  end

  field :image do
    noko.css('div#org_left img/@src').text
  end

  field :party do
    noko.css('#orgi_right').first.text.tidy
  end

  field :email do
    js = noko.css('#contact script').text.gsub(/document.getElementById.*?;/, '')
    var = js[/var (addy.*?)=/, 1]
    CGI.unescapeHTML(ExecJS.exec("#{js}; return #{var}"))
  end

  field :source do
    url
  end
end

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.sxmparliament.org/organization/members-of-parliament.html'

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
data = scrape(start => MembersPage).members.map { |m| m.to_h.merge(term: 4) }
# puts data.map { |r| r.reject { |_k, v| v.to_s.empty? }.sort_by { |k, _v| k }.to_h }
ScraperWiki.save_sqlite(%i(id term), data)
