require 'mechanize'
require 'nokogiri'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil
NUMBER_TEST_METRICS = 5

class Quiz
  attr_accessor :staq_results

  def initialize
    @staq_results = {}
  end

  def run
    agent = Mechanize.new
    agent.get("https://staqresults.staq.com") do |page|
      page.form_with(:action => '/sessions') do |f|
        f.email = "test@example.com"
        f.password = "secret"
      end.submit

      table = agent.get('https://staqresults.staq.com/reports').search("table")
      keys_in_th_head   = table.search("thead tr th.text-right")
      keys_in_td_body   = table.search("tbody tr td.date")
      values_in_td_body = table.search("tbody tr td.text-right")

      test_metrics = keys_in_th_head.map do |key_in_th_head|
        key_in_th_head.children.text.downcase.to_sym
      end

      sub_hash = {}
      index = 0

      keys_in_td_body.each do |el|
        counter = 0
        while counter < NUMBER_TEST_METRICS
          sub_key = test_metrics[counter]
          sub_hash[sub_key] = values_in_td_body[index].children.text
          index += 1
          counter += 1
        end
        key = el.children.text
        @staq_results[key] = sub_hash
        sub_hash = {}
      end
    end

    staq_results
  end
end

q = Quiz.new
q.run
