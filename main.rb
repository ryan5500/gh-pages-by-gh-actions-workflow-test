require 'nokogiri'
require 'open-uri'
require 'fileutils'

feed_url = 'http://jvndb.jvn.jp/rss/ja/jvndb.rdf'

# 改行を1 itemとしてparseしてしまうのでnoblanksオプションを追加
doc = Nokogiri::XML(URI.open(feed_url), &:noblanks)

doc.xpath('//xmlns:item').each do |item|
  item.remove if item.xpath('sec:cvss[@version="3.0" and @score < "8.0"]', 'sec': 'http://jvn.jp/rss/mod_sec/').size > 0
end

FileUtils.mkdir_p('./artifact')
File.open('./artifact/jvndb_upper8.rdf', 'w') do |f| 
  f.write doc.to_xml
end
