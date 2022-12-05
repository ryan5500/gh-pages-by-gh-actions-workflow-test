require 'nokogiri'
require 'open-uri'
require 'fileutils'


# refer: https://qiita.com/yama660/items/7f99180f23934017ff40
require 'net/http'
Net::HTTP.prepend Module.new {
  def use_ssl=(flag)
    super
    self.ciphers = "DEFAULT:!DH"
  end
}

feed_url = 'http://jvndb.jvn.jp/rss/ja/jvndb.rdf'

# 改行を1 itemとしてparseしてしまうのでnoblanksオプションを追加
doc = Nokogiri::XML(URI.open(feed_url), &:noblanks)

doc.xpath('//xmlns:item').each do |item|
  if item.xpath('sec:cvss[@version="3.0" and @score < "8.0"]', 'sec': 'http://jvn.jp/rss/mod_sec/').size > 0
    # 要素の一覧を指していると思しきchannel/items/rdf:Seq/rdf:liの要素を削除する
    resource_url = item.attributes['about']
    li_item = doc.xpath("//rdf:li[@rdf:resource='#{resource_url}']")
    li_item.remove

    item.remove
  end
end

FileUtils.mkdir_p('./artifact')
File.open('./artifact/jvndb_upper8.rdf', 'w') do |f| 
  f.write doc.to_xml
end
