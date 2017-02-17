# frozen_string_literal: true
require 'scraped'
require 'execjs'

class MemberDiv < Scraped::HTML
  field :id do
    email.sub(/@.*/, '')
  end

  field :name do
    name_parts.reject { |part| titles.include? part }.map(&:tidy).join(' ')
  end

  field :honorific_prefix do
    name_parts.select { |part| titles.include? part }.map(&:tidy).join(';')
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

  private

  def titles
    %(drs.)
  end

  def name_parts
    noko.css('#org_title').text.split(' ')
  end
end
