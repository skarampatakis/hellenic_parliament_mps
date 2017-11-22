# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful
#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'mechanize'

def scrap_mp(id, base)
  mp_url = base + "?MpId=" + id
  agent = Mechanize.new
  page = agent.get(mp_url)
  rows = page.search('tbody > tr:not(.tablefooter)')
  rows.each_with_index do |(row,row_key), row_index|
    terms = row.search("td")
    ScraperWiki.save_sqlite(["id"], {"id" => id + "|row|" + row_index.to_s,"hellenic_parliament_id" => id,
       "period" => terms[0].text,
       "date" => terms[1].text,
       "district" => terms[2].text,
       "party" => terms[3].text,
       "description" => terms[4].text
     }, 'terms')
  end
end

#
agent = Mechanize.new
#
# # Read in a page
url = "http://www.hellenicparliament.gr/Vouleftes/Diatelesantes-Vouleftes-Apo-Ti-Metapolitefsi-Os-Simera"
page = agent.get(url)
#
# # Find somehing on the page using css selectors
mp = page.search('select.mpsDropdown > option')
mp.each_with_index do |(value, key), index|
  if index < 4
    next
  end
  p index, value.text
  ScraperWiki.save_sqlite(["hellenic_parliament_id"], {"hellenic_parliament_id" => value.attr("value"), "full_name" => value.text})
  scrap_mp(value.attr("value"), url)
end


# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
