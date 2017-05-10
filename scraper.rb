#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.sxmparliament.org/organization/members-of-parliament.html'

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
data = scrape(start => MembersPage).members.map { |m| m.to_h.merge(term: 3) }
# puts data.map { |r| r.reject { |_k, v| v.to_s.empty? }.sort_by { |k, _v| k }.to_h }
ScraperWiki.save_sqlite(%i(id term), data)
