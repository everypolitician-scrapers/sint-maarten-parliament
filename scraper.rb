#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)

  noko.css('section.article-content div#o1').each do |mem|
    data = { 
      id: mem.css('div#org_left img/@src').text.split("/").last.gsub(/\..*?$/, ''),
      name: mem.css('#org_title').text.tidy,
      image: mem.css('div#org_left img/@src').text,
      party: mem.css('#orgi_right').first.text.tidy,
      term: 2,
      source: url,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://www.sxmparliament.org/organization/members-of-parliament.html')
