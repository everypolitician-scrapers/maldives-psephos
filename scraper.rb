#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'open-uri'
require 'colorize'
require 'csv'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def detabulate(header, rows)
  headings = header.split(/[[:space:]]+/)
  locn = headings.map { |h| header.index h }
  unpackmap = (1..locn.size - 1).to_a.map { |i| "A#{locn[i] - locn[i-1]}" }.join + "A*"
  rows.each_line.map { |l| l.chomp.unpack(unpackmap).map(&:strip) }.unshift(headings)
end

def table_as_csv(header, rows)
  detabbed = detabulate(header, rows)
  as_csv = detabbed.map { |l| l.to_csv }.join ""
  CSV.parse(as_csv, headers: true, header_converters: :symbol )
end
  


@file = 'http://psephos.adam-carr.net/countries/m/maldives/maldives20141.txt'
file = open(@file)
paras = file.readlines("\r\n\r\n")

paras.select { |p| p =~ /^Candidate/ }.each do |result|
  area, headers, results, total = result.split(/^[=\-]+\s*$/)
  csv = table_as_csv(headers.sub('%', 'percent').strip, results.strip)
  winner = csv.sort_by { |row| row[:votes].gsub(',','').to_i }.last
  data = { 
    name: winner[:candidate].strip,
    area: area.strip,
    party: winner[:party].strip,
    term: '2014',
  }
  ScraperWiki.save_sqlite([:name], data)
end

