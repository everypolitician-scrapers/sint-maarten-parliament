#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)

  noko.css('section.article-content div#o1').each do |mem|
    data = {
      id:     mem.css('div#org_left img/@src').text.split('/').last.gsub(/\..*?$/, ''),
      name:   mem.css('#org_title').text.tidy,
      image:  mem.css('div#org_left img/@src').text,
      party:  mem.css('#orgi_right').first.text.tidy,
      term:   3,
      source: url,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://www.sxmparliament.org/organization/members-of-parliament.html')
