# frozen_string_literal: true
require 'scraped'
require 'ExecJS'

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
