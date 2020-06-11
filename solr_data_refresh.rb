########################### solr_config.yaml ###########################
default: &default
  command: full-import
  reload_before_index: 'true'
  deviation_percentage: 10
  optimize: 'true'
  commit: 'true'
  max_time_for_indexing_minutes: 30
  user: solr-admin
  password: <%= ENV['SOLR_AUTH_PASSWORD'] %>
  core_name: <%= ENV['CORE_NAME'] %>

development:
  <<: *default
  master: http://localhost:8983/solr
  slaves:
    - http://localhost:8984/solr
    - http://localhost:8985/solr
    
########################## solr_data_refresh.rb #########################

#!/usr/bin/env ruby
require 'net/http'
require 'net/https'
require 'yaml'
require 'json'
require 'logger'
require 'erb'
# require 'byebug'

# Adding Equivalent of Rails method symbolize_keys
class Hash
  def symbolize_keys
    hash_new = {}
    self.each_pair do |key, value|
      hash_new[key.to_sym] = value
    end
    hash_new
  end
end

SOLR_CONFIG = YAML.load(ERB.new(File.read('solr_config.yaml')).result)[ENV['RAILS_ENV']].symbolize_keys

# log_file_name = "#{SOLR_CONFIG[:core_name]}_log.log"
# File.delete(log_file_name) if File.exist?(log_file_name)
# LOGGER = Logger.new(log_file_name)
LOGGER = Logger.new(STDOUT)

class SolrDihIndexTrigger
  class << self
    def handle_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end

    def post_form_with_basic_auth(base_uri, post_data = {}, raise_exception = true)
      uri = URI.parse(base_uri)
      http = handle_http(uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(SOLR_CONFIG[:user], SOLR_CONFIG[:password])
      request.set_form_data(post_data)

      response = http.request(request)
      LOGGER.info response.inspect
      raise response.body if (raise_exception && response.code != '200')
      response
    end

    def master_data_count
      base_uri = "#{SOLR_CONFIG[:master]}/#{SOLR_CONFIG[:core_name]}/select?q=*:*"
      post_data = {
        start: 0,
        rows: 0
      }

      response = post_form_with_basic_auth(base_uri, post_data)
      JSON.parse(response.body)['response']['numFound']
    end

    def data_import_status
      base_uri = "#{SOLR_CONFIG[:master]}/#{SOLR_CONFIG[:core_name]}/dataimport?wt=json"
      response = post_form_with_basic_auth(base_uri)
      JSON.parse(response.body)
    end

    def replicate_to_slaves
      SOLR_CONFIG[:slaves].each do |slave|
        replicate_url = "#{slave}/#{SOLR_CONFIG[:core_name]}/replication?wt=json&command=fetchindex"
        LOGGER.info "Replication URL: #{replicate_url}"
        post_form_with_basic_auth(replicate_url)
      end
    end

    def check_deviation(total_records)
      total_records_after = get_total_records
      LOGGER.info "Total records after indexing: #{total_records_after}"
      deviation = 100 * ((total_records_after - total_records).abs / total_records)
      if (SOLR_CONFIG[:deviation_percentage] > 0) && (deviation > SOLR_CONFIG[:deviation_percentage])
        raise "Deviation is more than expected #{deviation}"
      end
    end

    def wait_till_indexing_done
      elapsed_time_seconds = 0
      status_messages = nil
      status = ''
      while status != 'idle'
        sleep(20)
        elapsed_time_seconds += 20
        json_response = data_import_status
        status = json_response['status']
        status_messages = json_response['statusMessages']
        if (elapsed_time_seconds / 60) > SOLR_CONFIG[:max_time_for_indexing_minutes]
          raise "Taking too long to index"
        end
      end
      failed_time_stamp = status_messages['Full Import failed']
      raise "Indexing failed status: #{status_messages}" if !failed_time_stamp.nil?
      LOGGER.info status_messages
    end

    def trigger_index
        index_url = "#{SOLR_CONFIG[:master]}/#{SOLR_CONFIG[:core_name]}/dataimport?wt=json&command=#{SOLR_CONFIG[:command]}&commit=#{SOLR_CONFIG[:commit]}&optimize=#{SOLR_CONFIG[:optimize]}"
        LOGGER.info "Indexing using #{index_url}"
        post_form_with_basic_auth(index_url)
    end

    def reload_core
      if SOLR_CONFIG[:reload_before_index]
        reload_url = "#{SOLR_CONFIG[:master]}/admin/cores?action=RELOAD&wt=json&core=#{SOLR_CONFIG[:core_name]}"
        reload_response = post_form_with_basic_auth(reload_url)
        LOGGER.info "Reload response: #{reload_response.inspect}"
      end
    end

    def get_total_records
      total_records_before_url = "#{SOLR_CONFIG[:master]}/#{SOLR_CONFIG[:core_name]}/select?q=*&omitHeader=true&wt=json&rows=0"
      LOGGER.info "Total records URL: #{total_records_before_url}"
      total_records = master_data_count
      total_records
    end

    def data_refresh
      total_records = get_total_records
      LOGGER.info "Total records before indexing: #{total_records}"
      reload_core
      trigger_index
      wait_till_indexing_done
      check_deviation(total_records)
      replicate_to_slaves
    end
  end
end

SolrDihIndexTrigger.data_refresh
