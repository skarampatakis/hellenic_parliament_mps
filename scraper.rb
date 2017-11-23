# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful
#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'mechanize'

#a method to clean the period field
def clean_string(string, last=-15, start=18)
	string[start..last]
end

#a method to extract the dates from the period field
def extract_dates(string)
	str1 = ""
    string.sub(/(\(.*?\))/) { str1 = $1 }
    dates = str1[1..-2]
end

#a method to extract the start date from the period field
def start_date(string)
	string.split(" - ")[0]
end

#a method to extract the end date from the period field
def end_date(string)
	string.split(" - ")[1]
end

def scrap_mp(id, base)
  #create the url
  mp_url = base + "?MpId=" + id
  agent = Mechanize.new
  page = agent.get(mp_url)
  #get all table rows except footer
  rows = page.search('tbody > tr:not(.tablefooter)')
  rows.each_with_index do |(row,row_key), row_index|
    terms = row.search("td")
    #clean period field
    period = clean_string(terms[0].text, -16)
    #get the period greek alphabet enumeration
    suffix = period[0..3].rstrip[0..-2]
    #extract the dates
    dates = extract_dates(period)
    ScraperWiki.save_sqlite(["id"], {"id" => id + "|period|" + suffix,"hellenic_parliament_id" => id,
       "period" => period,
       "period_letter" => suffix,
       "date" => clean_string(terms[1].text),
       "start_date" => start_date(dates),
       "end_date" => end_date(dates),
       "district" => clean_string(terms[2].text),
       "party" => clean_string(terms[3].text),
       "description" => clean_string(terms[4].text)
     }, 'terms')
  end
end

#
agent = Mechanize.new
#
# drop terms table
ScraperWiki.sqliteexecute('DROP TABLE terms') rescue nil
# # Read in a page
url = "http://www.hellenicparliament.gr/Vouleftes/Diatelesantes-Vouleftes-Apo-Ti-Metapolitefsi-Os-Simera"
page = agent.get(url)
#
# # Find somehing on the page using css selectors
mp = page.search('select.mpsDropdown > option')
mp.each_with_index do |(value, key), index|
  # skip first 4 items as they contain empty elements
  if index < 4
    next
  end
  #give some output
  p index, value.text
  
  #create the mp
  ScraperWiki.save_sqlite(["hellenic_parliament_id"], {"hellenic_parliament_id" => value.attr("value"), "full_name" => value.text})
  #scrap terms info
  scrap_mp(value.attr("value"), url)
end

# query to get current members
# select distinct data.full_name, terms.period from data inner join terms on data.hellenic_parliament_id = terms.hellenic_parliament_id where period LIKE '%ΙΖ%'

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
